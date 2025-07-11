import apiClient from "./index";

const jsonToParams = (json) => {
  return new URLSearchParams(json).toString();
};

export const getTeams = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/teams?" + queryParams);
};

export const getTeam = (id) => apiClient.get(`/teams/${id}`);
export const deleteTeam = (id) => apiClient.delete(`/teams/${id}`);
export const createTeam = (body) => apiClient.post(`/teams`, body);
export const editTeam = (id, body) => apiClient.patch(`/teams/${id}`, body);
