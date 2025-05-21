Function capitalize = (String str) {
  if (str.isEmpty) return str;
  return str[0].toUpperCase() + str.substring(1);
};
