<template>
  <BaseList
    ref="baseList"
    title="Lista de Membros"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Adicionar Membro"
    :headers="headers"
    :items="members"
    :total-pages="totalPages"
    :is-loading="isLoading"
    :has-filters="true"
    :active-filters-count="activeFiltersCount"
    :initial-filters="{ active: true }"
    @fetch="handleFetch"
    @add-new="openCreateModal"
    @toggle-filters="showFiltersModal = true"
  >
    <template #active-filters>
      <div class="d-flex align-items-center justify-content-between">
        <span>
          <i class="filter-indicator"></i>
          {{ activeFiltersText }}
        </span>
        <button
          v-if="hasAnyFilters"
          class="btn btn-sm btn-outline-secondary"
          @click="clearAllFilters"
        >
          Limpar Filtros
        </button>
      </div>
    </template>

    <template #row="{ item: member }">
      <td>
        <div class="d-flex align-items-center">
          <div
            :class="member.active ? 'status-dot active' : 'status-dot inactive'"
            :title="
              member.active
                ? 'Ativo'
                : `Desativado em ${
                    member.disabled_at
                      ? new Date(member.disabled_at).toLocaleDateString(
                          'pt-BR',
                          {
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric',
                          }
                        )
                      : ''
                  }`
            "
          ></div>
          <button
            @click="openEditModal(member.id)"
            class="btn btn-link text-decoration-none ms-2 p-0 text-start"
          >
            {{ member.name }}
          </button>
        </div>
      </td>
      <td>
        <span v-if="member.external_id" class="badge bg-light text-dark">
          {{ member.external_id }}
        </span>
        <span v-else class="text-muted">-</span>
      </td>
      <td>
        <div
          v-if="member.teams && member.teams.length > 0"
          class="teams-container"
        >
          <div class="d-flex gap-1">
            <div
              v-for="team in member.teams"
              :key="team.id"
              class="d-flex align-items-center mb-1"
            >
              <button
                @click="openTeamModal(team.id)"
                class="btn btn-outline-primary btn-sm"
              >
                {{ team.name }}
              </button>
            </div>
          </div>
        </div>
        <span v-else>Nenhum time</span>
      </td>
      <td>
        <button
          v-if="member.total_seconds !== undefined"
          @click="openHoursReport(member)"
          class="btn btn-outline-primary btn-sm"
        >
          {{ formatHoursAndMinutes(member.total_seconds) }}
        </button>
        <span v-else class="text-muted">-</span>
      </td>
      <td>
        <div class="d-flex gap-2">
          <button
            class="btn btn-outline-secondary btn-sm"
            @click="openEditModal(member.id)"
          >
            Editar
          </button>
          <button
            :class="
              member.active
                ? 'btn btn-warning btn-sm'
                : 'btn btn-success btn-sm'
            "
            @click="toggleActive(member.id, !member.active)"
          >
            {{ member.active ? "Desativar" : "Ativar" }}
          </button>
        </div>
      </td>
    </template>
  </BaseList>

  <MemberModal
    :show="showModal"
    :member-id="selectedMemberId"
    @close="closeModal"
    @saved="handleMemberSaved"
  />

  <TeamModal
    :show="showTeamModal"
    :team-id="selectedTeamId"
    :all-members="allMembers"
    @close="closeTeamModal"
    @saved="handleTeamSaved"
  />

  <FiltersModal
    :show="showFiltersModal"
    @close="showFiltersModal = false"
    @apply="applyFilters"
    @clear="clearAllFilters"
  >
    <div class="row g-3">
      <div class="col-md-6">
        <label class="form-label">Status</label>
        <select class="form-select" v-model="filterActive">
          <option value="">Todos</option>
          <option :value="true">Ativos</option>
          <option :value="false">Inativos</option>
        </select>
      </div>
      <div class="col-md-6">
        <label class="form-label">RA do aluno</label>
        <input
          type="text"
          class="form-control"
          v-model="filterExternalId"
          @input="formatFilterExternalId"
          placeholder="Digite o RA do aluno"
        />
        <small class="form-text text-muted"> Apenas números </small>
      </div>
      <div class="col-md-12">
        <label class="form-label">Times</label>
        <select class="form-select" v-model="selectedTeamIds" multiple size="5">
          <option
            v-for="team in availableTeams"
            :key="team.id"
            :value="team.id"
          >
            {{ team.name }}
          </option>
        </select>
        <small class="form-text text-muted">
          Segure Ctrl/Cmd para selecionar múltiplos
        </small>
      </div>
    </div>
  </FiltersModal>

  <MemberHoursReport
    :show="showHoursReport"
    :member-id="selectedMemberForReport?.id"
    :member-data="selectedMemberForReport"
    @close="closeHoursReport"
  />
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getMembers, editMember } from "@/api/superadmin/members";
import { getTeams } from "@/api/superadmin/teams";
import BaseList from "../common/BaseList.vue";
import MemberModal from "./MemberModal.vue";
import FiltersModal from "../common/FiltersModal.vue";
import TeamModal from "../teams/TeamModal.vue";
import MemberHoursReport from "../reports/MemberHoursReport.vue";

export default {
  name: "MembersList",
  components: {
    BaseList,
    MemberModal,
    FiltersModal,
    TeamModal,
    MemberHoursReport,
  },
  data() {
    return {
      // ===== DADOS DA LISTA =====
      members: [],
      totalPages: 1,
      isLoading: true,
      headers: [
        { label: "Nome", key: "name", sortable: true },
        { label: "RA do aluno", key: "external_id", sortable: true },
        { label: "Times", key: "teams", sortable: false },
        { label: "Horas Totais", key: "total_hours", sortable: true },
        { label: "Ações", key: "actions", sortable: false },
      ],

      // ===== MODAIS =====
      showModal: false,
      showFiltersModal: false,
      selectedMemberId: null,
      showTeamModal: false,
      selectedTeamId: null,
      allMembers: [],

      // ===== FILTROS =====
      filterActive: true, // Padrão: apenas membros ativos
      selectedTeamIds: [], // Times selecionados para filtro
      availableTeams: [], // Lista de todos os times disponíveis
      filterExternalId: "", // Filtro por ID externo (RA do aluno)

      // ===== RELATÓRIO DE HORAS =====
      showHoursReport: false,
      selectedMemberForReport: null,
    };
  },
  computed: {
    activeFiltersCount() {
      let count = 0;
      if (this.filterActive === false || this.filterActive === "") count++; // Só conta se não for o padrão (true)
      if (this.selectedTeamIds.length > 0) count++;
      if (this.filterExternalId.trim() !== "") count++;
      return count;
    },

    hasAnyFilters() {
      return (
        this.filterActive !== true ||
        this.selectedTeamIds.length > 0 ||
        this.filterExternalId.trim() !== ""
      );
    },

    // Texto descritivo dos filtros ativos
    activeFiltersText() {
      const parts = [];

      // Status dos membros
      const statusText = this.getStatusText();
      parts.push(statusText);

      // Filtro por times
      const teamsText = this.getTeamsText();
      if (teamsText) parts.push(teamsText);

      // Filtro por ID externo (RA do aluno)
      const externalIdText = this.getExternalIdText();
      if (externalIdText) parts.push(externalIdText);

      return parts.join(" • ");
    },
  },
  mounted() {
    this.loadAvailableTeams();
  },
  methods: {
    // ===== MÉTODOS AUXILIARES =====
    getStatusText() {
      switch (this.filterActive) {
        case true:
          return "Exibindo apenas membros ativos";
        case false:
          return "Exibindo apenas membros inativos";
        case "":
          return "Exibindo todos os membros";
        default:
          return "Exibindo apenas membros ativos";
      }
    },

    getTeamsText() {
      if (this.selectedTeamIds.length === 0) return null;

      const teamNames = this.selectedTeamIds
        .map((id) => this.availableTeams.find((team) => team.id === id)?.name)
        .filter(Boolean);

      return `Times: ${teamNames.join(", ")}`;
    },

    getExternalIdText() {
      if (this.filterExternalId.trim() === "") return null;
      return `RA do aluno: ${this.filterExternalId}`;
    },

    formatFilterExternalId(event) {
      const value = event.target.value.replace(/\D/g, "");
      this.filterExternalId = value;
    },

    // ===== MÉTODOS PRINCIPAIS =====
    async handleFetch(params) {
      const requestParams = { ...params, with_hours: true };

      await handleRequest({
        request: () => getMembers(requestParams),
        processOnSuccess: (response) => {
          this.members = response.records;
          this.totalPages = response.total_pages || 1;
          this.isLoading = false;
        },
        errorMessage: "Erro ao buscar membros",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },
    // ===== AÇÕES DE MEMBROS =====
    async toggleActive(id, active) {
      const member = this.members.find((m) => m.id === id);
      const action = active ? "ativar" : "desativar";
      const confirmMessage = `Tem certeza que deseja ${action} o membro "${member.name}"?`;

      if (!confirm(confirmMessage)) return;

      await handleRequest({
        request: () => editMember(id, { active }),
        processOnSuccess: () => {
          // Reaplica os filtros atuais ao invés de resetar
          this.$refs.baseList?.fetchData();
        },
        successMessage: `Membro ${active ? "ativado" : "desativado"} com sucesso`,
        errorMessage: `Erro ao ${action} membro`,
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    // ===== MODAIS =====
    openCreateModal() {
      this.selectedMemberId = null;
      this.showModal = true;
    },

    openEditModal(memberId) {
      this.selectedMemberId = memberId;
      this.showModal = true;
    },

    closeModal() {
      this.showModal = false;
      this.selectedMemberId = null;
    },

    handleMemberSaved() {
      // Mantém os filtros atuais após salvar
      this.$refs.baseList?.fetchData();
    },

    // ===== FILTROS =====
    applyFilters() {
      const filters = {};

      filters.active = this.filterActive;

      if (this.selectedTeamIds.length > 0) {
        filters.team_ids = this.selectedTeamIds;
      }

      if (this.filterExternalId.trim() !== "") {
        filters.external_id = this.filterExternalId.trim();
      }

      this.$refs.baseList?.applyFilters(filters);
    },

    clearAllFilters() {
      this.filterActive = true;
      this.selectedTeamIds = [];
      this.filterExternalId = "";
      this.$refs.baseList?.resetToInitialState();
    },

    // ===== DADOS AUXILIARES =====
    async loadAvailableTeams() {
      await handleRequest({
        request: () => getTeams({ all_records: true }),
        processOnSuccess: (response) => {
          this.availableTeams = response.records;
        },
        errorMessage: "Erro ao carregar times",
        eventBus: this.$eventBus,
      });
    },

    openTeamModal(teamId) {
      this.ensureAllMembersLoaded();
      this.selectedTeamId = teamId;
      this.showTeamModal = true;
    },

    async ensureAllMembersLoaded() {
      if (this.allMembers.length === 0) {
        await handleRequest({
          request: () => getMembers({ all_records: true }),
          processOnSuccess: (response) => {
            this.allMembers = response.records || [];
          },
          errorMessage: "Erro ao buscar membros",
          eventBus: this.$eventBus,
        });
      }
    },

    closeTeamModal() {
      this.showTeamModal = false;
      this.selectedTeamId = null;
    },

    handleTeamSaved() {
      // Mantém os filtros atuais após salvar
      this.$refs.baseList?.fetchData();
    },

    // ===== RELATÓRIO DE HORAS =====
    openHoursReport(member) {
      this.selectedMemberForReport = member;
      this.showHoursReport = true;
    },

    closeHoursReport() {
      this.showHoursReport = false;
      this.selectedMemberForReport = null;
    },

    // ===== FORMATAÇÃO =====
    formatHoursAndMinutes(seconds) {
      if (!seconds || seconds === 0) return "0h 0min";
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      return `${hours}h ${minutes}min`;
    },
  },
};
</script>

<style scoped>
.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  display: inline-block;
  flex-shrink: 0;
}

.status-dot.active {
  background-color: #28a745;
}

.status-dot.inactive {
  background-color: #dc3545;
}

.btn-link.text-start {
  color: #0d6efd !important;
  font-weight: 500;
}

.btn-link.text-start:hover {
  color: #0a58ca !important;
  text-decoration: underline !important;
}

.filter-indicator::before {
  content: "🔍";
  margin-right: 0.5rem;
}

.btn-outline-info {
  color: #0dcaf0 !important;
  border-color: #0dcaf0 !important;
}

.btn-outline-info:hover {
  background-color: #0dcaf0 !important;
  border-color: #0dcaf0 !important;
  color: white !important;
}

.teams-container {
  max-width: 80%;
  overflow-x: auto;
  padding-bottom: 5px;
  white-space: nowrap;
}

.teams-container::-webkit-scrollbar {
  height: 6px;
}

.teams-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.teams-container::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

.teams-container::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>
