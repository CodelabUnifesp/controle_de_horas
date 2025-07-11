import { createStore } from "vuex";
import createPersistedState from 'vuex-persistedstate';
import sessionManager from "./modules/session_manager.js";

export default createStore({
  state: {},
  mutations: {},
  actions: {},
  modules: {
    sessionManager,
  },
  plugins: [createPersistedState()],
});