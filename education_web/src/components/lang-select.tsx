import React from 'react';
import { Select, MenuItem } from '@material-ui/core';

const LangSelect: React.FC<any> = ({
  value,
  onChange,
  items,
}) => {
  return (
    <Select
      value={value}
      onChange={onChange}
    >
      {items.map((item: any, key: number) => 
        <MenuItem key={key} value={key}>{item.text}</MenuItem>
      )}
    </Select>
  );
}

export default React.memo(LangSelect);