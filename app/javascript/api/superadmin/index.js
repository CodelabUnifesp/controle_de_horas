import axios from "axios";

const apiClient = axios.create({
  baseURL: `${window.location.origin}/api/v1/super_admin`,
  timeout: 20000,
  headers: {
    "Content-Type": "application/json",
    "Cache-Control": "no-cache",
    Pragma: "no-cache",
    Expires: "0",
  },
});

// Interceptor para adicionar o token
apiClient.interceptors.request.use(
  (config) => {
    config.headers["Authorization"] = localStorage.auth_token;
    return config;
  },
  (error) => Promise.reject(error)
);

apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => Promise.reject(error)
);

export default apiClient;
