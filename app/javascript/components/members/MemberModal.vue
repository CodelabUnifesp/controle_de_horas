<template>
  <BaseModal :show="show" :title="modalTitle" size="lg" @close="$emit('close')">
    <div v-if="loading" class="d-flex justify-content-center py-4">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>

    <form v-else @submit.prevent="submitForm">
      <div class="mb-3">
        <label for="member-name" class="form-label">Nome *</label>
        <input
          id="member-name"
          type="text"
          class="form-control"
          v-model="formData.name"
          required
        />
      </div>

      <div class="mb-3">
        <label for="member-pix" class="form-label">Chave PIX</label>
        <input
          id="member-pix"
          type="text"
          class="form-control"
          v-model="formData.pix_key"
        />
      </div>

      <div class="mb-3">
        <label for="member-external-id" class="form-label">RA do aluno</label>
        <input
          id="member-external-id"
          type="text"
          class="form-control"
          v-model="formData.external_id"
          @input="formatExternalId"
          placeholder="Ex: 12345678901"
        />
        <small class="form-text text-muted">
          Apenas números (pode começar com 0)
        </small>
      </div>

      <div v-if="isEditing && memberships.length > 0" class="mb-4">
        <h6 class="fw-bold mb-3">Times do Membro</h6>
        <div class="table-responsive">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>Time</th>
                <th>Função</th>
                <th width="100"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="membership in memberships" :key="membership.id">
                <td>{{ membership.team.name }}</td>
                <td class="text-capitalize">{{ membership.role }}</td>
                <td>
                  <button
                    type="button"
                    @click="removeMembership(membership.team_id)"
                    class="btn btn-outline-danger btn-sm"
                  >
                    Remover
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
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
import { getMember, createMember, editMember } from "@/api/superadmin/members";
import BaseModal from "../common/BaseModal.vue";

export default {
  name: "MemberModal",
  components: {
    BaseModal,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    memberId: {
      type: [String, Number],
      default: null,
    },
  },
  data() {
    return {
      formData: { name: "", pix_key: "", external_id: "" },
      member: null,
      memberships: [],
      loading: false,
    };
  },
  computed: {
    isEditing() {
      return !!this.memberId;
    },
    modalTitle() {
      return this.isEditing
        ? `Editar Membro: ${this.member?.name || ""}`
        : "Novo Membro";
    },
  },
  watch: {
    show(newVal) {
      if (newVal) {
        if (this.isEditing) {
          this.fetchMember();
        } else {
          this.resetForm();
        }
      }
    },
    memberId() {
      if (this.show && this.isEditing) {
        this.fetchMember();
      }
    },
  },
  methods: {
    resetForm() {
      this.formData = { name: "", pix_key: "", external_id: "" };
      this.member = null;
      this.memberships = [];
    },
    async fetchMember() {
      await handleRequest({
        request: () => getMember(this.memberId),
        processOnSuccess: (response) => {
          this.member = response.record;
          this.formData.name = response.record?.name || "";
          this.formData.pix_key = response.record?.pix_key || "";
          this.formData.external_id = response.record?.external_id || "";
          this.memberships = response.memberships.map((membership) => ({
            ...membership,
            team: response.teams.find((team) => team.id === membership.team_id),
          }));
        },
        errorMessage: "Erro ao buscar dados do membro",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loading = true;
        },
        processOnFinally: () => {
          this.loading = false;
        },
      });
    },
    async removeMembership(teamId) {
      if (!confirm("Tem certeza que deseja remover este membro do time?"))
        return;

      await handleRequest({
        request: () => removeMember(teamId, this.memberId),
        processOnSuccess: () => {
          this.memberships = this.memberships.filter(
            (m) => m.team_id !== teamId
          );
        },
        successMessage: "Membro removido do time com sucesso",
        errorMessage: "Erro ao remover membro do time",
        eventBus: this.$eventBus,
      });
    },
    async submitForm() {
      if (!this.formData.name.trim()) {
        this.$eventBus.emit("showAlert", {
          type: "error",
          message: "Nome é obrigatório",
        });
        return;
      }

      await handleRequest({
        request: () =>
          this.isEditing
            ? editMember(this.memberId, this.formData)
            : createMember(this.formData),
        processOnSuccess: () => {
          this.$emit("saved");
          this.$emit("close");
        },
        successMessage: "Membro salvo com sucesso",
        errorMessage: "Erro ao salvar membro",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loading = true;
        },
        processOnFinally: () => {
          this.loading = false;
        },
      });
    },
    formatExternalId(event) {
      const value = event.target.value.replace(/\D/g, "");
      this.formData.external_id = value;
    },
  },
};
</script>
