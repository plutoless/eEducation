import React from "react";
// @material-ui/core components
import { makeStyles } from "@material-ui/core/styles";
import Grid, { GridProps } from "@material-ui/core/Grid";

const styles = {
  grid: {
    padding: "0 15px !important"
  }
};

const useStyles = makeStyles(styles);

export interface GridItemProps extends GridProps {
  className?: string
  children?: any
}

const GridItem: React.FC<GridItemProps> = ({
  className,
  children,
  ...rest
}) => {
  const classes = useStyles();
  return (
    <Grid item {...rest} className={classes.grid + " " + className}>
      {children ? children : null}
    </Grid>
  );
}

export default GridItem;
