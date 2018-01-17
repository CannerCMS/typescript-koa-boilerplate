import {createApp} from "../app";
const port = process.env.NODE_PORT || 1234;

createApp().then(app => {
  app.listen(port, () => {
    // tslint:disable-next-line:no-console
    console.log(`listen on port ${port}`);
  });
});
