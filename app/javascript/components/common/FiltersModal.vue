<template>
  <BaseModal :show="show" title="Filtros" size="md" @close="$emit('close')">
    <slot />

    <template #footer>
      <button
        type="button"
        class="btn btn-outline-secondary"
        @click="clearFilters"
      >
        Limpar Filtros
      </button>
      <button type="button" class="btn btn-secondary" @click="$emit('close')">
        Fechar
      </button>
      <button type="button" class="btn btn-primary" @click="applyFilters">
        Aplicar Filtros
      </button>
    </template>
  </BaseModal>
</template>

<script>
import BaseModal from "./BaseModal.vue";

export default {
  name: "FiltersModal",
  components: {
    BaseModal,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
  },
  methods: {
    applyFilters() {
      this.$emit("apply");
      this.$emit("close");
    },
    clearFilters() {
      this.$emit("clear");
    },
  },
};
</script>
