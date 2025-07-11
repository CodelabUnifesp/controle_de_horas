<template>
  <div>
    <div class="container">
      <!-- Área de Aviso Informativo -->
      <div class="alert alert-info mb-4" role="alert">
        <div class="row">
          <div class="col-md-1 text-center">
            <i class="fas fa-info-circle fa-2x text-info"></i>
          </div>
          <div class="col-md-11">
            <h5 class="alert-heading mb-3">
              <i class="fas fa-calculator me-2"></i>
              Cálculo do relatório de horas
            </h5>
            <p class="mb-3">
              Para gerar seu relatório usamos dois tipos de métricas:
            </p>

            <div class="col-md-12">
              <div class="mb-3">
                <h6 class="text-primary">
                  <i class="fas fa-chart-line me-2"></i>
                  Métricas reais
                </h6>
                <p class="small mb-0">
                  Horas efetivamente registradas pelos líderes das equipes em
                  que você atuou, do primeiro ao último evento. Devem refletir
                  exatamente o que foi feito.
                </p>
              </div>
            </div>

            <div class="col-md-12">
              <div class="mb-3">
                <h6 class="text-success">
                  <i class="fas fa-bullseye me-2"></i>
                  Métricas ideais
                </h6>
                <p class="small mb-0">
                  O SIEX pede que o certificado mostre uma média de horas por
                  semana em número inteiro. Como algumas atividades duram menos
                  de uma hora e o número de tarefas muda a cada semana, o
                  sistema faz uma média e arredonda para facilitar.
                  <br />
                  <strong>Importante:</strong> o total de horas que vai no
                  certificado não muda, só o número de semanas pode ser
                  ajustado.
                </p>
              </div>
            </div>

            <div class="mt-2">
              <p class="mb-0 small">
                <i class="fas fa-search me-2"></i>
                <strong
                  >Você pode consultar abaixo tanto o relatório completo de
                  participação quanto a auditoria dos eventos em que esteve
                  presente.</strong
                >
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Relatório de Horas -->
      <div class="card">
        <div class="card-header">
          <h5 class="card-title mb-0">Relatório de Horas</h5>
        </div>
        <div class="card-body">
          <div class="row mb-4">
            <div class="col-md-8">
              <label for="memberSelect" class="form-label"
                >Selecione o Membro</label
              >
              <select
                id="memberSelect"
                v-model="selectedMemberId"
                class="form-select"
                @change="loadMemberReport"
                :disabled="isLoadingMembers"
              >
                <option value="">Selecione um membro...</option>
                <option
                  v-for="member in members"
                  :key="member.id"
                  :value="member.id"
                >
                  {{ member.name }}
                </option>
              </select>
              <div v-if="isLoadingMembers" class="text-muted mt-1">
                <small>Carregando membros...</small>
              </div>
            </div>
            <div class="col-md-4">
              <label for="memberSearch" class="form-label">Buscar Membro</label>
              <input
                id="memberSearch"
                v-model="searchTerm"
                @input="searchMembers"
                type="text"
                class="form-control"
                placeholder="Digite o nome do membro"
              />
            </div>
          </div>

          <HoursList
            v-if="selectedMemberId"
            :member-id="selectedMemberId"
            class="card-body"
          />

          <div v-else class="text-center text-muted py-5">
            <i class="fas fa-user-clock fa-3x mb-3"></i>
            <h5>Selecione um membro para visualizar o relatório de horas</h5>
            <p>
              Use o seletor acima para escolher um membro e visualizar suas
              métricas e eventos.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import HoursList from "./HoursList.vue";
import { getMembers } from "@/api/superadmin/members";
import { handleRequest } from "@/helper/request";

export default {
  components: {
    HoursList,
  },
  data() {
    return {
      selectedMemberId: "",
      members: [],
      searchTerm: "",
      isLoadingMembers: false,
      searchTimeout: null,
    };
  },
  computed: {
    ...mapGetters("sessionManager", ["getAuthToken"]),
  },
  mounted() {
    this.loadMembers();
  },
  methods: {
    async loadMembers(searchTerm = "") {
      this.isLoadingMembers = true;

      await handleRequest({
        request: () => getMembers({ name: searchTerm, all_records: true }),
        processOnSuccess: (response) => {
          this.members = response.records || [];
        },
        errorMessage: "Erro ao carregar membros",
        eventBus: this.$eventBus,
        processOnFinally: () => {
          this.isLoadingMembers = false;
        },
      });
    },

    searchMembers() {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        this.loadMembers(this.searchTerm);
      }, 300);
    },

    loadMemberReport() {
      // O componente HoursList será recarregado automaticamente devido ao :member-id
    },
  },
};
</script>

<style scoped>
.fa-user-clock {
  opacity: 0.3;
}

.alert-info {
  background: linear-gradient(135deg, #d1ecf1 0%, #bee5eb 100%);
  border: 1px solid #b8daff;
  border-radius: 15px;
  box-shadow: 0 4px 15px rgba(0, 123, 255, 0.1);
}

.alert-info .alert-heading {
  color: #0c5460;
  font-weight: 600;
}

.alert-info .text-primary {
  color: #0056b3 !important;
  font-weight: 600;
}

.alert-info .text-success {
  color: #155724 !important;
  font-weight: 600;
}

.alert-info .fas.fa-info-circle {
  color: #17a2b8 !important;
}

.alert-info p.small {
  line-height: 1.4;
  color: #495057;
}
</style>
