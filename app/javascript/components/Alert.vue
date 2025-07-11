<template>
  <div>
    <div
      v-if="isAlertVisible"
      class="alert alert-info alert-dismissible fade show"
      role="alert"
      :style="{ position: 'fixed', top: '20px', right: '20px', zIndex: 1050 }"
    >
      {{ alertMessage }}
    </div>
  </div>
</template>

<script>
import EventBus from "@/helper/eventBus";

export default {
  data() {
    return {
      isAlertVisible: false,
      alertMessage: "",
    };
  },
  created() {
    EventBus.on("displayAlert", this.showAlert);
  },
  methods: {
    showAlert(message) {
      this.alertMessage = message;
      this.isAlertVisible = true;
      setTimeout(() => {
        this.isAlertVisible = false;
      }, 3000);
    },
  },
  beforeUnmount() {
    EventBus.off("displayAlert", this.showAlert);
  },
};
</script>
