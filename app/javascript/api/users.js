import apiClient from "./index";

const jsonToParams = (json) => {
  return new URLSearchParams(json).toString();
};

export const getUserProfile = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/users/my_user?" + queryParams);
};

export const updateUserProfile = (body) =>
  apiClient.patch(`/users/update_my_user`, body);
