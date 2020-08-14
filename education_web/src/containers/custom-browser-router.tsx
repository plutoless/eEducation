import React from 'react';
import {HashRouter, Route, Router} from 'react-router-dom';

export const RouterContext = React.createContext({} as Router);

function CustomBrowserRouter ({children}: any) {
  return (
    <HashRouter>
      <Route>
        {(routeProps: any) => (
          <RouterContext.Provider value={routeProps}>
            {children}
          </RouterContext.Provider>
        )}
      </Route>
    </HashRouter>
  )
}

export default CustomBrowserRouter;