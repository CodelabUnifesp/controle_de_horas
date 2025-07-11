<template>
  <div class="container mt-5">
    <h1 class="text-center mb-4">Controle de Horas</h1>
    <h2 class="text-center mb-4">Codelab Teen</h2>
    <div class="card p-4 shadow">
      <div v-if="!isLoggedIn">
        <h3 class="text-center mb-4">Login</h3>
        <form @submit.prevent="onLogin">
          <div class="form-group mb-3">
            <label for="loginEmail">Email</label>
            <input
              type="email"
              id="loginEmail"
              v-model="loginEmail"
              class="form-control"
              placeholder="Digite seu email"
              required
            />
          </div>
          <div class="form-group mb-3">
            <label for="loginPassword">Senha</label>
            <input
              type="password"
              id="loginPassword"
              v-model="loginPassword"
              class="form-control"
              placeholder="Digite sua senha"
              required
            />
          </div>
          <button type="submit" class="btn btn-primary">Login</button>
          <span v-if="loginError" class="text-danger ml-2">{{
            loginError
          }}</span>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import "@/store/index.js";
import { mapActions, mapGetters } from "vuex";

export default {
  name: "SessionManager",

  computed: {
    ...mapGetters("sessionManager", [
      "getAuthToken",
      "getUserEmail",
      "getUserID",
      "isLoggedIn",
    ]),
  },

  data() {
    return {
      loginEmail: "",
      loginPassword: "",
      loginError: "",
      isLoading: false,
    };
  },

  watch: {
    isLoggedIn(newVal) {
      if (newVal) this.$router.push({ name: "Home" });
    },
  },

  methods: {
    ...mapActions("sessionManager", ["loginUser", "logoutUser"]),

    async onLogin(event) {
      const data = {
        user: {
          email: this.loginEmail,
          password: this.loginPassword,
        },
      };

      await handleRequest({
        request: () => this.loginUser(data),
        processOnSuccess: () => {
          this.resetData();
        },
        successMessage: "Login realizado com sucesso.",
        errorMessage: "Erro ao fazer login.",
        eventBus: this.$eventBus,
        processOnFinally: () => {
          this.isLoading = false;
        },
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnError: () => {
          this.loginError = "Erro ao fazer login.";
        },
      });
    },

    resetData() {
      this.loginEmail = "";
      this.loginPassword = "";
      this.loginError = "";
    },
  },
};
</script>

<style scoped></style>
