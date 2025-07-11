import axios from "axios";

const BASE_URL = "http://localhost:3000/";

const state = {
  auth_token: null,
  user: {
    id: null,
    username: null,
    email: null,
    super_admin: false,
  },
};
const getters = {
  getAuthToken(state) {
    return state.auth_token;
  },
  getUserEmail(state) {
    return state.user?.email;
  },
  getUserID(state) {
    return state.user?.id;
  },
  isLoggedIn(state) {
    const loggedOut =
      state.auth_token == null || state.auth_token == JSON.stringify(null);
    return !loggedOut;
  },
  isSuperAdmin(state) {
    return state.user?.super_admin;
  },
};
const actions = {
  async loginUser({ commit }, payload) {
    commit("resetUserInfo");

    return new Promise((resolve, reject) => {
      axios.defaults.headers.common["Authorization"] = null;

      axios
        .post(`${BASE_URL}users/sign_in`, payload)
        .then((response) => {
          commit("setUserInfo", response);
          resolve(response);
        })
        .catch((error) => {
          if (error.response?.status === 401) {
            commit("resetUserInfo");
          }
          reject(error);
        });
    });
  },
  logoutUser({ commit }) {
    const config = {
      headers: {
        Authorization: state.auth_token || localStorage.auth_token,
      },
    };

    return new Promise((resolve, reject) => {
      axios
        .delete(`${BASE_URL}users/sign_out`, config)
        .then(() => {
          commit("resetUserInfo");
          resolve();
        })
        .catch((error) => {
          commit("resetUserInfo");
          reject(error);
        });
    });
  },
};
const mutations = {
  setUserInfo(state, data) {
    state.user = data.data.user;
    state.auth_token = data.headers.authorization;
    axios.defaults.headers.common["Authorization"] = data.headers.authorization;
    localStorage.setItem("auth_token", data.headers.authorization);
    localStorage.setItem("user", JSON.stringify(data.data.user));
  },
  setUserInfoFromToken(state, data) {
    state.user = data.data.user;
    state.auth_token = localStorage.getItem("auth_token");
    state.user = {
      id: null,
      username: null,
      email: null,
      super_admin: false,
    };
    state.auth_token = null;
    localStorage.removeItem("auth_token");
    localStorage.removeItem("user");
    axios.defaults.headers.common["Authorization"] = null;
  },
  resetUserInfo(state) {
    state.user = {
      id: null,
      username: null,
      email: null,
      super_admin: false,
    };
    state.auth_token = null;
    localStorage.removeItem("auth_token");
    localStorage.removeItem("user");
    axios.defaults.headers.common["Authorization"] = null;
  },
};
export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
