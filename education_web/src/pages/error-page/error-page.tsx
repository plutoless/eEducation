import React from 'react';
import GridContainer from '@/components/grid/grid-container';
import { makeStyles } from "@material-ui/core/styles";
import styles from './index.scss';
import GridItem from '@/components/grid/grid-item';
import { useErrorState } from '@/containers/root-container';
import {ErrorState} from './state';

const useStyles = makeStyles(styles);

const ErrorPage: React.FC<ErrorState> = ({
  reason,
  errors,
}) => {
  const classes = useStyles();
  return (
    <div className={classes.contentCenter}>
      <GridContainer>
        <GridItem md={12}>
          <h1 className={classes.title}>{reason}</h1>
          {/* <h2 className={classes.subTitle}>Page not found :(</h2> */}
          <h4 className={classes.description}>
            {/* {show error} */}
          </h4>
        </GridItem>
      </GridContainer>
    </div>
  );
}

const ErrorPageProvider: React.FC<any> = () => {
  const errorState = useErrorState();
  return (
    <ErrorPage {...errorState}></ErrorPage>
  )
}
export default ErrorPageProvider;