<template>
  <div id="app">
    <AlertBox />

    <nav
      v-if="isLoggedIn"
      class="navbar navbar-expand-lg navbar-dark bg-danger fixed-top shadow"
    >
      <div
        class="container-fluid d-flex justify-content-center align-items-center"
      >
        <div class="d-flex gap-3 align-items-center">
          <router-link to="/" class="navbar-brand m-0">
            <div
              class="bg-white rounded-pill p-2 d-flex justify-content-center align-items-center"
            >
              <img
                :src="codelabTeenLogoUrl"
                alt="Codelab Teen Logo"
                style="height: 20px"
              />
            </div>
          </router-link>
          <!-- <router-link to="/" class="navbar-brand m-0">
            <div
              class="bg-white rounded-pill p-2 d-flex justify-content-center align-items-center"
            >
              <img
                :src="unifespLogoUrl"
                alt="Unifesp Logo"
                style="height: 30px"
              />
            </div>
          </router-link> -->
        </div>

        <button
          class="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarNav"
          aria-controls="navbarNav"
          aria-expanded="false"
          aria-label="Alternar navegação"
        >
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
          <ul class="navbar-nav me-auto mb-2 mb-lg-0">
            <li class="nav-item" v-if="isSuperAdmin">
              <router-link to="/" class="nav-link" active-class="active" exact>
                Relatórios
              </router-link>
            </li>
            <li class="nav-item" v-if="isSuperAdmin">
              <router-link to="/members" class="nav-link" active-class="active"
                >Membros</router-link
              >
            </li>
            <li class="nav-item" v-if="isSuperAdmin">
              <router-link to="/teams" class="nav-link" active-class="active"
                >Times</router-link
              >
            </li>
            <li class="nav-item">
              <router-link to="/events" class="nav-link" active-class="active"
                >Eventos</router-link
              >
            </li>
          </ul>
          <ul class="navbar-nav">
            <li class="nav-item" v-if="isLoggedIn">
              <router-link to="/profile" class="nav-link" active-class="active">
                Meu Perfil
              </router-link>
            </li>
            <li class="nav-item" v-if="!isLoggedIn">
              <router-link to="/login" class="nav-link btn btn-outline-light"
                >Login</router-link
              >
            </li>
            <li class="nav-item" v-if="isLoggedIn">
              <button @click="logout" class="nav-link btn btn-outline-light">
                Logout
              </button>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <div class="content mt-5 pt-4">
      <router-view />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import AlertBox from "./Alert.vue";
import unifespLogo from "../images/unifesp-logo.png";
import codelabTeenLogo from "../images/codelab-teen-logo.png";

export default {
  name: "App",
  components: {
    AlertBox,
  },
  computed: {
    ...mapGetters("sessionManager", ["isLoggedIn", "isSuperAdmin"]),
    unifespLogoUrl() {
      return unifespLogo;
    },
    codelabTeenLogoUrl() {
      return codelabTeenLogo;
    },
  },
  methods: {
    ...mapActions("sessionManager", ["logoutUser"]),
    logout() {
      this.logoutUser();
      this.$router.push({ name: "Login" });
    },
  },
};
</script>
<style lang=""></style>
