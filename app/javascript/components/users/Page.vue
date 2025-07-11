<template>
  <div class="container my-4">
    <div class="card shadow">
      <div class="card-header bg-primary text-white">
        <h3 class="mb-0">Meu Perfil</h3>
      </div>
      <div class="card-body">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Carregando...</span>
          </div>
        </div>

        <div v-else>
          <div v-if="editMode" class="mb-3">
            <form @submit.prevent="updateProfile">
              <div class="mb-3">
                <label for="name" class="form-label">Nome</label>
                <input
                  type="text"
                  class="form-control"
                  id="name"
                  v-model="editedUser.name"
                  placeholder="Seu nome"
                />
              </div>

              <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input
                  type="email"
                  class="form-control"
                  id="email"
                  v-model="editedUser.email"
                  placeholder="seu.email@exemplo.com"
                />
              </div>

              <hr class="my-4" />
              <h5 class="mb-3">Alterar Senha</h5>
              <p class="text-muted small">
                Deixe os campos de senha em branco para não a alterar.
              </p>

              <div class="mb-3">
                <label for="current_password" class="form-label"
                  >Senha Atual</label
                >
                <input
                  type="password"
                  class="form-control"
                  id="current_password"
                  v-model="editedUser.current_password"
                  placeholder="Informe sua senha atual para trocar"
                />
              </div>

              <div class="mb-3">
                <label for="password" class="form-label">Nova Senha</label>
                <input
                  type="password"
                  class="form-control"
                  id="password"
                  v-model="editedUser.password"
                  placeholder="Mínimo de 6 caracteres"
                />
              </div>

              <div class="mb-3">
                <label for="password_confirmation" class="form-label"
                  >Confirmar Nova Senha</label
                >
                <input
                  type="password"
                  class="form-control"
                  id="password_confirmation"
                  v-model="editedUser.password_confirmation"
                  placeholder="Repita a nova senha"
                />
              </div>

              <div class="d-flex justify-content-end">
                <button
                  type="button"
                  class="btn btn-secondary me-2"
                  @click="cancelEdit"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  class="btn btn-primary"
                  :disabled="saving"
                >
                  <span
                    v-if="saving"
                    class="spinner-border spinner-border-sm me-1"
                    role="status"
                  ></span>
                  Salvar
                </button>
              </div>
            </form>
          </div>

          <div v-else>
            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Nome:</div>
              <div class="col-md-9">
                {{ userProfile.name || "(Não informado)" }}
              </div>
            </div>

            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Email:</div>
              <div class="col-md-9">{{ userProfile.email }}</div>
            </div>

            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Administrador do sistema:</div>
              <div class="col-md-9">
                {{ userProfile.super_admin ? "Sim" : "Não" }}
              </div>
            </div>

            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Criado em:</div>
              <div class="col-md-9">
                {{ formatDate(userProfile.created_at) }}
              </div>
            </div>

            <div class="d-flex justify-content-end">
              <button class="btn btn-primary" @click="enableEdit">
                Editar Perfil
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getUserProfile, updateUserProfile } from "@/api/users";

export default {
  name: "UserProfile",

  data() {
    return {
      loading: true,
      saving: false,
      editMode: false,
      userProfile: {},
      editedUser: {
        name: "",
        email: "",
        current_password: "",
        password: "",
        password_confirmation: "",
      },
    };
  },

  created() {
    this.fetchUserProfile();
  },

  methods: {
    async fetchUserProfile(params) {
      await handleRequest({
        request: () => getUserProfile(params),
        processOnSuccess: (response) => {
          this.userProfile = response.record;
        },
        errorMessage: "Erro ao buscar perfil",
        eventBus: this.$eventBus,
        processOnFinally: () => {
          this.loading = false;
        },
      });
    },

    enableEdit() {
      this.editedUser = {
        name: this.userProfile.name,
        email: this.userProfile.email,
        current_password: "",
        password: "",
        password_confirmation: "",
      };
      this.editMode = true;
    },

    cancelEdit() {
      this.editMode = false;
    },

    async updateProfile() {
      if (this.editedUser.password !== this.editedUser.password_confirmation) {
        this.$eventBus.emit("showAlert", {
          type: "error",
          message: "A nova senha e a confirmação não correspondem.",
        });
        return;
      }

      if (this.editedUser.password && !this.editedUser.current_password) {
        this.$eventBus.emit("showAlert", {
          type: "error",
          message:
            "Por favor, informe sua senha atual para definir uma nova senha.",
        });
        return;
      }

      await handleRequest({
        request: () => updateUserProfile({ user: this.editedUser }),
        processOnSuccess: (response) => {
          this.userProfile = response.record;
          this.editMode = false;
        },
        successMessage: "Perfil atualizado com sucesso!",
        errorMessage: "Erro ao atualizar perfil",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.saving = true;
        },
        processOnFinally: () => {
          this.saving = false;
        },
      });
    },

    formatDate(dateString) {
      if (!dateString) return "";

      const date = new Date(dateString);
      return new Intl.DateTimeFormat("pt-BR", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      }).format(date);
    },
  },
};
</script>
