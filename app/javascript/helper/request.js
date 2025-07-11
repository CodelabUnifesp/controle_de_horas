/**
 * Handles API requests with standardized error handling and callbacks
 * @param {Object} options - The request configuration options
 * @param {Function} options.request - The actual API request function to execute
 * @param {Function} [options.processOnStart] - Callback to run before the request starts
 * @param {Function} [options.processOnSuccess] - Callback to run on successful response
 * @param {string} [options.successMessage='Requisição processada com sucesso!'] - Default success message
 * @param {Function} [options.processOnError] - Callback to run on error
 * @param {string} [options.errorMessage='Erro ao processar requisição'] - Default error message
 * @param {Function} [options.processOnFinally] - Callback to run after request completes
 * @param {Object} [options.eventBus] - Event bus for displaying messages
 * @returns {Promise<Object>} The API response data
 */
export const handleRequest = async ({
  request,
  processOnStart = undefined,
  processOnSuccess = undefined,
  successMessage,
  processOnError = undefined,
  errorMessage = "Erro ao processar requisição",
  processOnFinally = undefined,
  eventBus = undefined,
}) => {
  try {
    if (processOnStart) processOnStart();
    const response = await request();

    const message = successMessage || response.message;
    if (eventBus && message) eventBus.emit("displayAlert", message);

    if (processOnSuccess) processOnSuccess(response);
    return response;
  } catch (error) {
    const message =
      error.response?.data?.error ||
      error?.response?.data?.errors?.[0] ||
      errorMessage;
    if (eventBus && message) eventBus.emit("displayAlert", message);

    if (processOnError) processOnError(error);
  } finally {
    if (processOnFinally) processOnFinally();
  }
};
