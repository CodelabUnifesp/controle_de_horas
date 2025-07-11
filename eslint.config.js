import eslintPluginVue from "eslint-plugin-vue";
import eslintPluginImport from "eslint-plugin-import";
import eslintPluginPromise from "eslint-plugin-promise";
import eslintPluginPrettier from "eslint-plugin-prettier";

export default [
  {
    files: ["*.js", "*.jsx", "*.ts", "*.tsx", "*.vue"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
    },
    plugins: {
      vue: eslintPluginVue,
      import: eslintPluginImport,
      promise: eslintPluginPromise,
      prettier: eslintPluginPrettier,
    },
    rules: {
      // Boas práticas gerais
      "no-unused-vars": "warn",
      "no-console": "warn",

      // Import plugin
      "import/order": [
        "warn",
        {
          groups: [
            "builtin",
            "external",
            "internal",
            "parent",
            "sibling",
            "index",
          ],
          "newlines-between": "always",
        },
      ],

      // Promises
      "promise/always-return": "warn",
      "promise/no-return-wrap": "error",

      // Prettier
      "prettier/prettier": "warn",

      // Vue specific
      "vue/no-unused-components": "warn",
      "vue/multi-word-component-names": "off",
      "vue/no-mutating-props": "error",
    },
  },
];
