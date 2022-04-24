const APPLOAD = require("./appload");



const app = new APPLOAD()
  app.onReady();
  


  async function test1(){

    const testNode = await app.addNodeType("test",[20,55,25,20,10,10,10,10,10]);
    
    console.log("TU MARCHERA",testNode);
  }

  async function test2(){

    const testNode = await app.getTotalCreatedNodes();
    
    await console.log("TU MARCHERA",testNode);
  }
  

  async function test3(){

    const testNode = await app.getNodeTypeAll("test");
    
   await console.log("TU MARCHERA",testNode._method);
  }
  

  test3();

