<template>
  <BaseModal :show="show" :title="title" size="xl" @close="$emit('close')">
    <div v-if="loading" class="d-flex justify-content-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>

    <form v-else @submit.prevent="submitForm">
      <div class="col-md-12">
        <div class="mb-3">
          <label for="title" class="form-label">Nome*</label>
          <input
            id="title"
            v-model="formData.title"
            type="text"
            class="form-control"
            required
          />
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label">Times*</label>
        <VueMultiselect
          v-model="selectedTeams"
          :options="teams"
          :multiple="true"
          :close-on-select="false"
          :preserve-search="true"
          placeholder="Selecione os times"
          label="name"
          track-by="id"
          @update:model-value="handleTeamChange"
        />
      </div>

      <div class="mb-3">
        <label class="form-label">Membros do Evento</label>
        <div v-if="selectedTeams.length === 0" class="alert alert-info">
          Selecione pelo menos um time para adicionar membros.
        </div>
        <VueMultiselect
          v-else
          v-model="eventMembers"
          :options="availableMembers"
          :multiple="true"
          :close-on-select="false"
          :preserve-search="true"
          :searchable="true"
          placeholder="Busque e selecione membros..."
          label="name"
          track-by="id"
        />
      </div>

      <div class="col-md-12">
        <div class="mb-3">
          <label for="duration" class="form-label">Duração*</label>
          <select
            id="duration"
            v-model="formData.duration_seconds"
            class="form-control"
            required
          >
            <option value="" disabled>Selecione a duração</option>
            <option value="900">15 minutos</option>
            <option value="1800">30 minutos</option>
            <option value="3600">1 hora</option>
            <option value="7200">2 horas</option>
            <option value="10800">3 horas</option>
            <option value="14400">4 horas</option>
          </select>
        </div>
      </div>

      <div class="col-md-12">
        <div class="mb-3">
          <label for="occurred_at" class="form-label">Data do Evento*</label>
          <input
            id="occurred_at"
            v-model="formData.occurred_at"
            type="date"
            class="form-control"
            required
          />
        </div>
      </div>

      <div class="col-md-12">
        <div class="mb-3">
          <label for="description" class="form-label">Descrição</label>
          <textarea
            id="description"
            v-model="formData.description"
            class="form-control"
            rows="3"
          ></textarea>
        </div>
      </div>
    </form>

    <template #footer>
      <button type="button" class="btn btn-secondary" @click="$emit('close')">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        @click="submitForm"
        :disabled="loading"
      >
        {{ loading ? "Salvando..." : "Salvar" }}
      </button>
    </template>
  </BaseModal>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getEvent, createEvent, editEvent } from "@/api/events";
import { getTeams } from "@/api/teams";
import { getMembers } from "@/api/members";
import BaseModal from "../common/BaseModal.vue";
import VueMultiselect from "vue-multiselect";

export default {
  name: "EventModal",
  components: { BaseModal, VueMultiselect },

  props: {
    show: { type: Boolean, default: false },
    eventId: { type: [String, Number], default: null },
  },

  data() {
    return {
      loading: false,
      formData: {
        title: "",
        description: "",
        duration_seconds: "",
        occurred_at: "",
      },
      event: null,
      teams: [],
      selectedTeams: [],
      eventMembers: [],
      availableMembers: [],
    };
  },

  computed: {
    isEditing() {
      return !!this.eventId;
    },
    title() {
      return this.isEditing
        ? `Editar Evento: ${this.event?.title || ""}`
        : "Novo Evento";
    },
    teamIds() {
      return this.selectedTeams.map((team) => team.id);
    },
  },

  watch: {
    show(newVal) {
      if (newVal) {
        this.loadData();
      } else {
        this.resetForm();
      }
    },
  },

  methods: {
    resetForm() {
      this.formData = {
        title: "",
        description: "",
        duration_seconds: "",
        occurred_at: "",
      };
      this.event = null;
      this.selectedTeams = [];
      this.eventMembers = [];
      this.availableMembers = [];
    },

    async loadData() {
      this.resetForm();
      await this.fetchTeams();
      if (this.isEditing) {
        await this.fetchEvent();
      }
    },

    async fetchTeams() {
      await handleRequest({
        request: () => getTeams({ all_records: true }),
        processOnSuccess: (response) => (this.teams = response.records),
        errorMessage: "Erro ao carregar times",
        eventBus: this.$eventBus,
      });
    },

    async fetchEvent() {
      await handleRequest({
        request: () => getEvent(this.eventId),
        processOnSuccess: (response) => {
          const record = response.record;
          this.event = record;
          this.formData = { ...this.formData, ...record };

          if (record.teams?.length) {
            this.selectedTeams = record.teams;
          } else if (record.team_ids?.length) {
            this.selectedTeams = this.teams.filter((team) =>
              record.team_ids.includes(team.id)
            );
          }

          if (record.occurred_at) {
            this.formData.occurred_at = record.occurred_at.split("T")[0];
          }

          if (this.selectedTeams.length > 0) {
            this.fetchMembers().then(() => {
              this.eventMembers = record.members || [];
            });
          } else {
            this.eventMembers = record.members || [];
          }
        },
        errorMessage: "Erro ao buscar evento",
        eventBus: this.$eventBus,
        processOnStart: () => (this.loading = true),
        processOnFinally: () => (this.loading = false),
      });
    },

    async fetchMembers() {
      if (this.selectedTeams.length === 0) return Promise.resolve();

      return handleRequest({
        request: () =>
          getMembers({ all_records: true, team_ids: this.teamIds }),
        processOnSuccess: (response) => {
          this.availableMembers = response.records || [];
          this.filterValidMembers();
        },
        errorMessage: "Erro ao carregar membros",
        eventBus: this.$eventBus,
      });
    },

    async handleTeamChange() {
      if (this.selectedTeams.length === 0) {
        this.eventMembers = [];
        this.availableMembers = [];
        return;
      }

      await this.fetchMembers();
    },

    filterValidMembers() {
      if (!this.availableMembers.length) return;

      const validMemberIds = this.availableMembers.map((m) => m.id);
      this.eventMembers = this.eventMembers.filter((member) =>
        validMemberIds.includes(member.id)
      );
    },

    async submitForm() {
      const eventData = {
        ...this.formData,
        team_ids: this.teamIds,
        member_ids: this.eventMembers.map((m) => m.id),
      };

      await handleRequest({
        request: () =>
          this.isEditing
            ? editEvent(this.eventId, eventData)
            : createEvent(eventData),
        processOnSuccess: () => {
          this.$emit("saved");
          this.$emit("close");
        },
        successMessage: `Evento ${this.isEditing ? "salvo" : "criado"} com sucesso`,
        errorMessage: `Erro ao ${this.isEditing ? "salvar" : "criar"} evento`,
        eventBus: this.$eventBus,
        processOnStart: () => (this.loading = true),
        processOnFinally: () => (this.loading = false),
      });
    },
  },
};
</script>

<style src="vue-multiselect/dist/vue-multiselect.css"></style>
<style scoped>
:deep(.modal-dialog) {
  max-width: 800px;
  width: 90%;
}

:deep(.modal-content) {
  max-height: 90vh;
  overflow-y: auto;
}

:deep(.multiselect__tags) {
  min-height: 40px;
  max-height: 120px;
  overflow-y: auto;
  padding: 8px 40px 0 8px;
}

:deep(.multiselect__tag) {
  background: #007bff;
  color: white;
  border-radius: 4px;
  padding: 4px 8px;
  margin: 2px 4px 2px 0;
  font-size: 12px;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

:deep(.multiselect__tag-icon:hover) {
  background: rgba(255, 255, 255, 0.3);
}

@media (max-width: 768px) {
  :deep(.modal-dialog) {
    max-width: 95%;
    margin: 10px auto;
  }

  :deep(.multiselect__tags) {
    max-height: 80px;
  }

  :deep(.multiselect__tag) {
    max-width: 150px;
    font-size: 11px;
  }
}
</style>
