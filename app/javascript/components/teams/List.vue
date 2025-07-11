<template>
  <BaseList
    title="Lista de Times"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Adicionar Time"
    :headers="headers"
    :items="teams"
    :total-pages="totalPages"
    :is-loading="isLoading"
    @fetch="handleFetch"
    @add-new="openCreateModal"
  >
    <template #row="{ item: team }">
      <td>
        <button
          @click="openEditModal(team.id)"
          class="btn btn-link text-decoration-none p-0 text-start"
        >
          {{ team.name }}
        </button>
      </td>
      <td>
        <button @click="openEditModal(team.id)" class="btn btn-info btn-sm">
          {{ team.member_count || 0 }}
        </button>
      </td>
      <td>
        <div class="d-flex gap-2">
          <button
            class="btn btn-outline-secondary btn-sm"
            @click="openEditModal(team.id)"
          >
            Editar
          </button>
          <button class="btn btn-danger btn-sm" @click="deleteRecord(team.id)">
            Excluir
          </button>
        </div>
      </td>
    </template>
  </BaseList>

  <TeamModal
    :show="showModal"
    :team-id="selectedTeamId"
    :all-members="allMembers"
    @close="closeModal"
    @saved="handleTeamSaved"
  />
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getTeams, deleteTeam } from "@/api/superadmin/teams";
import { getMembers } from "@/api/superadmin/members";
import BaseList from "../common/BaseList.vue";
import TeamModal from "./TeamModal.vue";

export default {
  name: "TeamsList",
  components: {
    BaseList,
    TeamModal,
  },
  data() {
    return {
      teams: [],
      totalPages: 1,
      isLoading: true,
      showModal: false,
      selectedTeamId: null,
      allMembers: [],
      headers: [
        { label: "Nome", key: "name", sortable: true },
        { label: "Membros", key: "member_count", sortable: true },
        { label: "Ações", key: "actions", sortable: false },
      ],
    };
  },
  methods: {
    async handleFetch(params) {
      await handleRequest({
        request: () => getTeams(params),
        processOnSuccess: (response) => {
          this.teams = response.records;
          this.totalPages = response.total_pages || 1;
          this.isLoading = false;
        },
        errorMessage: "Erro ao buscar times",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    async deleteRecord(id) {
      if (
        confirm("Tem certeza que deseja excluir PERMANENTEMENTE este time?")
      ) {
        await handleRequest({
          request: () => deleteTeam(id),
          processOnSuccess: () => {
            this.handleFetch({ page: 1 });
          },
          successMessage: "Time excluído com sucesso",
          errorMessage: "Erro ao excluir time",
          eventBus: this.$eventBus,
        });
      }
    },

    async openCreateModal() {
      await this.ensureMembersLoaded();
      this.selectedTeamId = null;
      this.showModal = true;
    },

    async openEditModal(teamId) {
      await this.ensureMembersLoaded();
      this.selectedTeamId = teamId;
      this.showModal = true;
    },

    async ensureMembersLoaded() {
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

    closeModal() {
      this.showModal = false;
      this.selectedTeamId = null;
    },

    handleTeamSaved() {
      this.handleFetch({ page: 1 });
    },
  },
};
</script>

<style scoped>
.btn-link.text-start {
  color: #0d6efd !important;
  font-weight: 500;
}

.btn-link.text-start:hover {
  color: #0a58ca !important;
  text-decoration: underline !important;
}
</style>
