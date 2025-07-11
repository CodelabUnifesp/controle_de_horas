import apiClient from "./index";
import { jsonToParams } from "./utils";

export const getEvents = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/events?" + queryParams);
};

export const getEvent = (id) => apiClient.get(`/events/${id}`);
export const deleteEvent = (id) => apiClient.delete(`/events/${id}`);
export const createEvent = (body) => apiClient.post(`/events`, body);
export const editEvent = (id, body) => apiClient.patch(`/events/${id}`, body);
