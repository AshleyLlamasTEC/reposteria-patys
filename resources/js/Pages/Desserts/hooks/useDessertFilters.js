import { useMemo, useState } from 'react';
import { filterDesserts } from '../utils/dessert.filters';
import { sortDesserts } from '../utils/dessert.sorter';

export function useDessertFilters(initialDesserts = []) {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [priceRange, setPriceRange] = useState([0, 1000]);
  const [sortBy, setSortBy] = useState('popular');

  const desserts = useMemo(() => {
    return Array.isArray(initialDesserts) ? initialDesserts : [];
  }, [initialDesserts]);

  const filteredDesserts = useMemo(() => {
    return filterDesserts(desserts, {
      searchQuery,
      category: selectedCategory,
      priceRange,
    });
  }, [desserts, searchQuery, selectedCategory, priceRange]);

  const sortedDesserts = useMemo(() => {
    return sortDesserts(filteredDesserts, sortBy);
  }, [filteredDesserts, sortBy]);

  const totalCount = desserts.length;
  const filteredCount = sortedDesserts.length;

  const resetFilters = () => {
    setSearchQuery('');
    setSelectedCategory('all');
    setPriceRange([0, 1000]);
    setSortBy('popular');
  };

  return {
    desserts,
    filteredDesserts: sortedDesserts,
    totalCount,
    filteredCount,
    searchQuery,
    selectedCategory,
    priceRange,
    sortBy,
    setSearchQuery,
    setSelectedCategory,
    setPriceRange,
    setSortBy,
    resetFilters,
  };
}
