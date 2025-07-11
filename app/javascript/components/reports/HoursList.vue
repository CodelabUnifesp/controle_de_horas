<template>
  <div v-if="memberReport">
    <div class="row mb-4">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header">
            <h6 class="card-title mb-0">
              <i class="fas fa-user"></i> {{ memberReport.name }}
            </h6>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-2">
                <div class="text-center">
                  <h4 class="text-primary mb-1">
                    {{ formatTotalHours(memberReport.total_seconds) }}
                  </h4>
                  <small class="text-muted">Total de Horas</small>
                </div>
              </div>
              <div class="col-md-2">
                <div class="text-center">
                  <h4 class="text-success mb-1">
                    {{ memberReport.event_count }}
                  </h4>
                  <small class="text-muted">Total de Eventos</small>
                </div>
              </div>
              <div class="col-md-2">
                <div class="text-center">
                  <h4 class="text-info mb-1">
                    {{ memberReport.real.total_weeks }}
                  </h4>
                  <small class="text-muted">Semanas Reais</small>
                </div>
              </div>
              <div class="col-md-3">
                <div class="text-center">
                  <h4 class="text-warning mb-1">
                    {{ formatDate(memberReport.created_at) }}
                  </h4>
                  <small class="text-muted">Membro desde</small>
                </div>
              </div>
              <div class="col-md-3">
                <div class="text-center">
                  <h4 class="text-danger mb-1">
                    {{ formatDate(memberReport.disabled_at) || "—" }}
                  </h4>
                  <small class="text-muted">Desativado em</small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="row mb-4">
      <div class="col-md-6">
        <div class="card">
          <div class="card-header">
            <h6 class="card-title mb-0">
              <i class="fas fa-chart-line"></i> Métricas Reais
            </h6>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-12 mb-3">
                <strong>Média por Semana:</strong>
                <span class="badge bg-primary ms-2">{{
                  formatWeeklyAverage(
                    memberReport.total_seconds,
                    memberReport.real.total_weeks
                  )
                }}</span>
              </div>
              <div class="col-12 mb-3">
                <strong>Primeiro Evento:</strong>
                <span class="text-muted">{{
                  formatDateTime(memberReport.real.first_event_at)
                }}</span>
              </div>
              <div class="col-12 mb-3">
                <strong>Último Evento:</strong>
                <span class="text-muted">{{
                  formatDateTime(memberReport.real.last_event_at)
                }}</span>
              </div>
              <div class="col-12">
                <strong>Período:</strong>
                <span class="text-muted"
                  >{{ memberReport.real.total_weeks }} semanas</span
                >
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-md-6">
        <div class="card">
          <div class="card-header">
            <h6 class="card-title mb-0">
              <i class="fas fa-bullseye"></i> Métricas Ideais
            </h6>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-12 mb-3">
                <strong>Média por Semana:</strong>
                <span class="badge bg-success ms-2"
                  >{{ memberReport.ideal.average_hours_per_week }}h</span
                >
              </div>
              <div class="col-12 mb-3">
                <strong>Início Ideal:</strong>
                <span class="text-muted">{{
                  formatDateTime(memberReport.ideal.first_event_at)
                }}</span>
              </div>
              <div class="col-12 mb-3">
                <strong>Fim Ideal:</strong>
                <span class="text-muted">{{
                  formatDateTime(memberReport.ideal.last_event_at)
                }}</span>
              </div>
              <div class="col-12">
                <strong>Período:</strong>
                <span class="text-muted"
                  >{{ memberReport.ideal.total_weeks }} semanas</span
                >
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header">
            <h6 class="card-title mb-0">
              <i class="fas fa-calendar-alt"></i> Eventos ({{
                memberReport.events.length
              }})
            </h6>
          </div>
          <div class="card-body">
            <div
              v-if="memberReport.events.length === 0"
              class="text-center text-muted py-4"
            >
              <i class="fas fa-calendar-times fa-2x mb-2"></i>
              <p>Nenhum evento encontrado para este membro.</p>
            </div>
            <div v-else class="table-responsive">
              <table class="table table-hover">
                <thead>
                  <tr>
                    <th>Data</th>
                    <th>Evento</th>
                    <th>Duração</th>
                    <th>Times</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="event in memberReport.events" :key="event.id">
                    <td>
                      <small class="text-muted">{{
                        formatDateTime(event.occurred_at)
                      }}</small>
                    </td>
                    <td>
                      <div>
                        <strong>{{ event.title }}</strong>
                        <div v-if="event.description" class="text-muted small">
                          {{ event.description }}
                        </div>
                      </div>
                    </td>
                    <td>
                      <span class="badge bg-light text-dark">
                        {{ formatDuration(event.duration_seconds) }}
                      </span>
                    </td>
                    <td>
                      <div v-if="event.teams.length > 0">
                        <span
                          v-for="team in event.teams"
                          :key="team.id"
                          class="badge bg-secondary me-1"
                        >
                          {{ team.name }}
                        </span>
                      </div>
                      <span v-else class="text-muted">—</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div v-else-if="isLoading" class="text-center py-5">
    <div class="spinner-border text-primary" role="status">
      <span class="visually-hidden">Carregando...</span>
    </div>
    <p class="mt-2 text-muted">Carregando relatório...</p>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getHoursReport } from "@/api/superadmin/reports";

export default {
  name: "HoursList",
  props: {
    memberId: {
      type: [String, Number],
      required: true,
    },
  },
  data() {
    return {
      memberReport: null,
      isLoading: false,
    };
  },
  watch: {
    memberId: {
      handler: "loadMemberReport",
      immediate: true,
    },
  },
  methods: {
    async loadMemberReport() {
      if (!this.memberId) return;

      this.isLoading = true;
      this.memberReport = null;

      await handleRequest({
        request: () => getHoursReport({ member_id: this.memberId }),
        processOnSuccess: (response) => {
          this.memberReport = response.record;
        },
        errorMessage: "Erro ao carregar relatório do membro",
        eventBus: this.$eventBus,
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    formatTotalHours(seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      return `${hours}h ${minutes}m`;
    },

    formatDuration(seconds) {
      if (seconds < 3600) {
        return `${Math.floor(seconds / 60)}min`;
      }
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
    },

    formatWeeklyAverage(totalSeconds, totalWeeks) {
      if (!totalSeconds || !totalWeeks || totalWeeks === 0) return "0h 0m";

      const averageSecondsPerWeek = totalSeconds / totalWeeks;
      const hours = Math.floor(averageSecondsPerWeek / 3600);
      const minutes = Math.floor((averageSecondsPerWeek % 3600) / 60);

      return `${hours}h ${minutes}m`;
    },

    formatDate(dateString) {
      if (!dateString) return "—";

      return new Date(dateString).toLocaleDateString("pt-BR", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      });
    },

    formatDateTime(dateString) {
      if (!dateString) return "—";

      return new Date(dateString).toLocaleDateString("pt-BR", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      });
    },
  },
};
</script>

<style scoped>
.table th {
  font-weight: 600;
  font-size: 0.875rem;
  color: #6c757d;
  border-bottom: 2px solid #dee2e6;
}

.card-title {
  color: #495057;
}

.badge {
  font-size: 0.75rem;
}

.fa-calendar-times {
  opacity: 0.3;
}
</style>
