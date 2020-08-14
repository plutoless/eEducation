import React from "react";
// @material-ui/core components
import { makeStyles } from "@material-ui/core/styles";
import Grid, { GridProps } from "@material-ui/core/Grid";

const styles = {
  grid: {
    margin: "0 -15px",
    width: "calc(100% + 30px)"
    // '&:before,&:after':{
    //   display: 'table',
    //   content: '" "',
    // },
    // '&:after':{
    //   clear: 'both',
    // }
  }
};

const useStyles = makeStyles(styles);

export interface GridContainerProps extends GridProps {
  className?: string
  children?: any
}

const GridContainer: React.FC<GridContainerProps> = ({
  className,
  children,
  ...rest
}) => {
  const classes = useStyles();
  return (
    <Grid container {...rest} className={classes.grid + " " + className}>
      {children ? children : null}
    </Grid>
  );
}


export default GridContainer;