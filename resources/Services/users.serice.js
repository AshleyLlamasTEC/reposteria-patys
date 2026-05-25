export const formatUserForTable = (user) => ({
  ...user,
  displayStatus: user.active ? 'Activo' : 'Inactivo',
});