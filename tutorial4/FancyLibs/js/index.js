import BatchedBridge from "react-native/Libraries/BatchedBridge/BatchedBridge";
import AppRegistry from 'react-native';

export class CommonInterface {
  helloworld(message) {
      alert("Hello World\n" + message);  
  }
}

const exposed = new CommonInterface();
BatchedBridge.registerCallableModule("CommonInterface", exposed);

