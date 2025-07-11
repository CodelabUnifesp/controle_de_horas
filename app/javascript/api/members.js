import apiClient from "./index";
import { jsonToParams } from "./utils";

export const getMembers = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/members?" + queryParams);
};

export const getMember = (id) => apiClient.get(`/members/${id}`);
