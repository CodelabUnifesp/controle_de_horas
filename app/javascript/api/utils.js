export const jsonToParams = (json) => {
  const params = new URLSearchParams();

  Object.keys(json).forEach((key) => {
    const value = json[key];

    if (Array.isArray(value)) {
      // Para arrays, adiciona cada item com [] no nome do parâmetro
      value.forEach((item) => {
        params.append(`${key}[]`, item);
      });
    } else if (value !== null && value !== undefined && value !== "") {
      params.append(key, value);
    }
  });

  return params.toString();
};
