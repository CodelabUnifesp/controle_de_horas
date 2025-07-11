import apiClient from "./index";

const jsonToParams = (json) => {
  return new URLSearchParams(json).toString();
};

export const getHoursReport = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/reports/hours?" + queryParams);
};
