<template>
  <div class="container mt-5">
    <h1 class="mb-4">{{ title }}</h1>

    <!-- Action Bar -->
    <div class="action-bar mb-4">
      <div class="search-section">
        <div class="input-group">
          <input
            type="text"
            class="form-control"
            :placeholder="searchPlaceholder"
            v-model="searchTerm"
            @input="handleSearch"
          />
          <button
            v-if="hasFilters"
            class="btn btn-outline-secondary"
            type="button"
            @click="$emit('toggle-filters')"
            :class="{ 'btn-primary': hasActiveFilters }"
            :title="hasActiveFilters ? 'Filtros ativos' : 'Filtros'"
          >
            <i class="filter-icon"></i>
            <span v-if="hasActiveFilters" class="filter-badge"></span>
          </button>
        </div>
      </div>

      <div class="actions-section" v-if="addButtonText">
        <button
          v-if="!newItemRoute"
          @click="$emit('add-new')"
          class="btn btn-success"
        >
          <i class="plus-icon"></i>
          {{ addButtonText }}
        </button>
        <router-link v-else :to="newItemRoute" class="btn btn-success">
          <i class="plus-icon"></i>
          {{ addButtonText }}
        </router-link>
      </div>
    </div>

    <!-- Active Filters Display -->
    <div v-if="$slots['active-filters']" class="active-filters-display mb-3">
      <slot name="active-filters" />
    </div>

    <table class="table table-striped table-bordered">
      <thead class="thead-dark">
        <tr>
          <th
            scope="col"
            v-for="header in computedHeaders"
            :key="header.key || header"
            :class="{ 'sortable-header': header.sortable }"
            @click="header.sortable ? toggleSort(header.key) : null"
          >
            <div class="d-flex align-items-center justify-content-between">
              <span>{{ header.label || header }}</span>
              <div v-if="header.sortable" class="sort-icons">
                <i
                  class="sort-icon"
                  :class="{
                    'sort-active': currentSort.field === header.key,
                    'sort-asc':
                      currentSort.field === header.key &&
                      currentSort.order === 'asc',
                    'sort-desc':
                      currentSort.field === header.key &&
                      currentSort.order === 'desc',
                  }"
                ></i>
              </div>
            </div>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="isLoading">
          <td :colspan="computedHeaders.length" class="text-center">
            Carregando...
          </td>
        </tr>
        <tr v-else v-for="item in items" :key="item.id">
          <slot name="row" :item="item"></slot>
        </tr>
      </tbody>
    </table>

    <nav aria-label="Page navigation example">
      <ul class="pagination justify-content-center">
        <li class="page-item" :class="{ disabled: currentPage === 1 }">
          <a
            class="page-link"
            href="#"
            @click.prevent="changePage(currentPage - 1)"
          >
            Anterior
          </a>
        </li>

        <li
          class="page-item"
          v-for="page in totalPages"
          :key="page"
          :class="{ active: currentPage === page }"
        >
          <a class="page-link" href="#" @click.prevent="changePage(page)">
            {{ page }}
          </a>
        </li>

        <li class="page-item" :class="{ disabled: currentPage === totalPages }">
          <a
            class="page-link"
            href="#"
            @click.prevent="changePage(currentPage + 1)"
          >
            Próximo
          </a>
        </li>
      </ul>
    </nav>
  </div>
</template>

<script>
import debounce from "lodash.debounce";
import { mapGetters } from "vuex";

export default {
  name: "BaseList",
  props: {
    title: {
      type: String,
      required: true,
    },
    searchPlaceholder: {
      type: String,
      default: "Pesquisar",
    },
    addButtonText: {
      type: String,
      required: true,
    },
    newItemRoute: {
      type: String,
      default: null,
    },
    headers: {
      type: Array,
      required: true,
    },
    fetchFunction: {
      type: Function,
      required: true,
    },
    items: {
      type: Array,
      required: true,
    },
    totalPages: {
      type: Number,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
    hasFilters: {
      type: Boolean,
      default: false,
    },
    activeFiltersCount: {
      type: Number,
      default: 0,
    },
    initialFilters: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      searchTerm: "",
      currentPage: 1,
      currentSort: {
        field: null,
        order: "asc",
      },
      filters: { ...this.initialFilters },
    };
  },
  computed: {
    ...mapGetters("sessionManager", ["getAuthToken"]),
    computedHeaders() {
      return this.headers.map((header) => {
        if (typeof header === "string") {
          return { label: header, key: header.toLowerCase(), sortable: false };
        }
        return {
          label: header.label || header.key,
          key: header.key,
          sortable: header.sortable || false,
        };
      });
    },
    hasActiveFilters() {
      return this.activeFiltersCount > 0;
    },
  },
  watch: {
    searchTerm() {
      this.currentPage = 1;
    },
  },
  created() {
    this.handleSearch = debounce(this.fetchData, 300);
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      const params = {
        page: this.currentPage,
        name: this.searchTerm,
        title: this.searchTerm,
        ...this.filters,
      };

      if (this.currentSort.field) {
        params.sort_by = this.currentSort.field;
        params.sort_order = this.currentSort.order;
      }

      this.$emit("fetch", params);
    },
    changePage(page) {
      if (page < 1 || page > this.totalPages) return;
      this.currentPage = page;
      this.fetchData();
    },
    toggleSort(field) {
      if (this.currentSort.field === field) {
        this.currentSort.order =
          this.currentSort.order === "asc" ? "desc" : "asc";
      } else {
        this.currentSort.field = field;
        this.currentSort.order = "asc";
      }
      this.currentPage = 1;
      this.fetchData();
    },
    applyFilters(newFilters) {
      this.filters = { ...this.filters, ...newFilters };
      this.currentPage = 1;
      this.fetchData();
    },
    clearFilters() {
      this.filters = {};
      this.currentPage = 1;
      this.fetchData();
    },
    resetToInitialState() {
      this.searchTerm = "";
      this.filters = { ...this.initialFilters };
      this.currentPage = 1;
      this.currentSort = {
        field: null,
        order: "asc",
      };
      this.fetchData();
    },
  },
};
</script>

<style scoped>
.sortable-header {
  cursor: pointer;
  user-select: none;
}

.sortable-header:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.sort-icon {
  width: 0;
  height: 0;
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-bottom: 6px solid #ccc;
  opacity: 0.3;
  transition: opacity 0.2s;
}

.sort-icon.sort-active {
  opacity: 1;
}

.sort-icon.sort-desc {
  border-bottom: none;
  border-top: 6px solid #007bff;
}

.sort-icon.sort-asc {
  border-bottom: 6px solid #007bff;
}

.card {
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
}

.card-body {
  padding: 1rem;
}

.card-title {
  margin-bottom: 0.5rem;
  font-size: 1rem;
  font-weight: 500;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.search-section {
  flex: 1;
  min-width: 300px;
}

.actions-section {
  flex-shrink: 0;
}

.filter-icon::before {
  content: "⚙";
  font-size: 14px;
}

.plus-icon::before {
  content: "+";
  font-weight: bold;
  margin-right: 0.5rem;
}

.btn .filter-badge {
  position: absolute;
  top: -2px;
  right: -2px;
  width: 8px;
  height: 8px;
  background-color: #dc3545;
  border-radius: 50%;
  border: 1px solid white;
}

.btn {
  position: relative;
}

@media (max-width: 768px) {
  .action-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-section {
    min-width: 100%;
  }
}

.active-filters-display {
  padding: 0.5rem 1rem;
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  color: #6c757d;
}
</style>
