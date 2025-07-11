import apiClient from "./index";
import { jsonToParams } from "../utils";

export const getMembers = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/members?" + queryParams);
};

export const getMember = (id) => apiClient.get(`/members/${id}`);
export const createMember = (body) => apiClient.post(`/members`, body);
export const editMember = (id, body) => apiClient.patch(`/members/${id}`, body);
