import { createConsumer } from '@rails/actioncable';

const ActionCableApp = {};
ActionCableApp.cable = createConsumer('ws://localhost:3000/cable');
console.log('WebSocket connection established:', ActionCableApp.cable);

export default ActionCableApp;