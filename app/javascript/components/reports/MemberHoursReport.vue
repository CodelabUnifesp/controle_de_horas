<template>
  <BaseModal
    :show="show"
    title="Relatório de Horas"
    size="lg"
    @close="$emit('close')"
  >
    <div v-if="memberData" class="mb-4">
      <h5 class="mb-3">{{ memberData.name }}</h5>
      <div class="row">
        <div class="col-md-6">
          <div class="text-center p-3 bg-light rounded">
            <h6 class="mb-1">Total de Horas</h6>
            <h4 class="text-primary mb-0">
              {{ formatHoursAndMinutes(memberData.total_seconds) }}
            </h4>
          </div>
        </div>
        <div class="col-md-6">
          <div class="text-center p-3 bg-light rounded">
            <h6 class="mb-1">Total de Eventos</h6>
            <h4 class="text-info mb-0">{{ memberData.event_count || 0 }}</h4>
          </div>
        </div>
      </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <h6 class="mb-0">Histórico de Eventos</h6>
      <div class="d-flex gap-2">
        <input
          type="date"
          class="form-control form-control-sm"
          v-model="filterDateFrom"
          placeholder="Data inicial"
          @change="fetchEvents"
        />
        <input
          type="date"
          class="form-control form-control-sm"
          v-model="filterDateTo"
          placeholder="Data final"
          @change="fetchEvents"
        />
        <button class="btn btn-outline-secondary btn-sm" @click="clearFilter">
          Limpar
        </button>
      </div>
    </div>

    <div v-if="isLoading" class="text-center py-4">
      <div class="spinner-border" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>

    <div v-else-if="events.length === 0" class="text-center py-4 text-muted">
      Nenhum evento encontrado no período selecionado
    </div>

    <div v-else>
      <div class="table-responsive">
        <table class="table table-striped">
          <thead>
            <tr>
              <th>Data</th>
              <th>Título</th>
              <th>Time</th>
              <th>Duração</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="event in events" :key="event.id">
              <td>
                {{ formatDate(event.occurred_at) }}
              </td>
              <td>{{ event.title }}</td>
              <td>
                <span v-if="event.team" class="badge bg-primary">
                  {{ event.team.name }}
                </span>
                <span v-else class="text-muted">Sem time</span>
              </td>
              <td>{{ formatDuration(event.duration_seconds) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="totalPages > 1" class="mt-3">
        <nav>
          <ul class="pagination justify-content-center">
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <button class="page-link" @click="goToPage(currentPage - 1)">
                Anterior
              </button>
            </li>
            <li
              v-for="page in visiblePages"
              :key="page"
              class="page-item"
              :class="{ active: page === currentPage }"
            >
              <button class="page-link" @click="goToPage(page)">
                {{ page }}
              </button>
            </li>
            <li
              class="page-item"
              :class="{ disabled: currentPage === totalPages }"
            >
              <button class="page-link" @click="goToPage(currentPage + 1)">
                Próxima
              </button>
            </li>
          </ul>
        </nav>
      </div>
    </div>
  </BaseModal>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getEvents } from "@/api/events";
import BaseModal from "../common/BaseModal.vue";

export default {
  name: "MemberHoursReport",
  components: {
    BaseModal,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    memberId: {
      type: [Number, String],
      default: null,
    },
    memberData: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      events: [],
      isLoading: false,
      currentPage: 1,
      totalPages: 1,
      filterDateFrom: "",
      filterDateTo: "",
    };
  },
  computed: {
    visiblePages() {
      const pages = [];
      const start = Math.max(1, this.currentPage - 2);
      const end = Math.min(this.totalPages, this.currentPage + 2);

      for (let i = start; i <= end; i++) {
        pages.push(i);
      }

      return pages;
    },
  },
  watch: {
    show(newVal) {
      if (newVal && this.memberId) {
        this.currentPage = 1;
        this.fetchEvents();
      }
    },
    memberId() {
      if (this.show && this.memberId) {
        this.currentPage = 1;
        this.fetchEvents();
      }
    },
  },
  methods: {
    async fetchEvents() {
      if (!this.memberId) return;

      const params = {
        member_id: this.memberId,
        page: this.currentPage,
        sort_by: "occurred_at",
        sort_order: "desc",
      };

      if (this.filterDateFrom) {
        params.occurred_from = this.filterDateFrom;
      }

      if (this.filterDateTo) {
        params.occurred_to = this.filterDateTo;
      }

      await handleRequest({
        request: () => getEvents(params),
        processOnSuccess: (response) => {
          this.events = response.records || [];
          this.totalPages = response.total_pages || 1;
        },
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
        errorMessage: "Erro ao carregar eventos do membro",
        eventBus: this.$eventBus,
      });
    },

    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page;
        this.fetchEvents();
      }
    },

    clearFilter() {
      this.filterDateFrom = "";
      this.filterDateTo = "";
      this.currentPage = 1;
      this.fetchEvents();
    },

    formatDate(dateString) {
      if (!dateString) return "";

      const date = new Date(dateString);
      // Adjust for timezone offset to prevent day-before issues
      const userTimezoneOffset = date.getTimezoneOffset() * 60000;
      return new Date(date.getTime() + userTimezoneOffset).toLocaleDateString(
        "pt-BR",
        {
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
        }
      );
    },

    formatHoursAndMinutes(seconds) {
      if (!seconds || seconds === 0) return "0h 0min";
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      return `${hours}h ${minutes}min`;
    },

    formatDuration(seconds) {
      if (!seconds) return "0min";

      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);

      if (hours > 0) {
        return `${hours}h ${minutes}min`;
      }
      return `${minutes}min`;
    },
  },
};
</script>

<style scoped>
.table th {
  background-color: #f8f9fa;
  font-weight: 600;
  border-bottom: 2px solid #dee2e6;
}

.pagination .page-link {
  color: #0d6efd;
}

.pagination .page-item.active .page-link {
  background-color: #0d6efd;
  border-color: #0d6efd;
}

.bg-light {
  background-color: #f8f9fa !important;
}

.text-primary {
  color: #0d6efd !important;
}

.text-info {
  color: #0dcaf0 !important;
}

.text-success {
  color: #198754 !important;
}
</style>
