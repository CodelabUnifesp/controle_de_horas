<template>
  <BaseModal :show="show" :title="modalTitle" size="xl" @close="$emit('close')">
    <div v-if="loading" class="d-flex justify-content-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>
    <form v-else @submit.prevent="submitForm">
      <div class="mb-3">
        <label for="title" class="form-label">Nome*</label>
        <input
          id="title"
          v-model="formData.name"
          type="text"
          class="form-control"
          required
        />
      </div>

      <div class="mb-3">
        <label class="form-label">Membros do Time</label>
        <VueMultiselect
          v-model="teamMembers"
          :options="allMembers"
          :multiple="true"
          :close-on-select="false"
          :preserve-search="true"
          :searchable="true"
          placeholder="Busque e selecione membros..."
          label="name"
          track-by="id"
        />
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
import { getTeam, createTeam, editTeam } from "@/api/superadmin/teams";
import BaseModal from "../common/BaseModal.vue";
import VueMultiselect from "vue-multiselect";

export default {
  name: "TeamModal",
  components: {
    BaseModal,
    VueMultiselect,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    teamId: {
      type: [String, Number],
      default: null,
    },
    allMembers: {
      type: Array,
      default: () => [],
    },
  },
  data() {
    return {
      formData: {
        name: "",
      },
      team: null,
      loading: false,
      teamMembers: [],
    };
  },
  computed: {
    isEditing() {
      return !!this.teamId;
    },
    modalTitle() {
      return this.isEditing
        ? `Editar Time: ${this.team?.name || ""}`
        : "Novo Time";
    },
  },
  watch: {
    show(newVal) {
      if (newVal) {
        this.loadModalData();
      } else {
        this.resetForm();
      }
    },
  },
  methods: {
    resetForm() {
      this.formData = {
        name: "",
      };
      this.team = null;
      this.teamMembers = [];
    },

    async loadModalData() {
      this.resetForm();
      if (this.isEditing) {
        await this.fetchTeam();
      }
    },

    async fetchTeam() {
      await handleRequest({
        request: () => getTeam(this.teamId),
        processOnSuccess: (response) => {
          const record = response.record;
          this.team = record;
          this.formData = { ...this.formData, ...record };
          this.teamMembers = response.members || [];
        },
        errorMessage: "Erro ao buscar dados do time",
        eventBus: this.$eventBus,
        processOnStart: () => (this.loading = true),
        processOnFinally: () => (this.loading = false),
      });
    },

    async submitForm() {
      const teamData = {
        ...this.formData,
        member_ids: this.teamMembers.map((m) => m.id),
      };

      await handleRequest({
        request: () =>
          this.isEditing
            ? editTeam(this.teamId, teamData)
            : createTeam(teamData),
        processOnSuccess: (response) => {
          this.$emit("saved", response.record);
          this.$emit("close");
        },
        successMessage: `Time ${
          this.isEditing ? "salvo" : "criado"
        } com sucesso`,
        errorMessage: `Erro ao ${this.isEditing ? "salvar" : "criar"} time`,
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

:deep(.multiselect__content-wrapper) {
  position: absolute;
  z-index: 1050;
  max-height: 200px;
  overflow-y: auto;
  background: white;
  border: 1px solid #e3e3e3;
  border-radius: 4px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

:deep(.modal-body) {
  overflow: visible;
  min-height: 300px;
}

:deep(.modal-content) {
  overflow: visible;
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
