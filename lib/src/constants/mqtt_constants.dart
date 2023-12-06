const String indentifier = 'gardenifi_app';
const String baseTopic = '/raspirri';
const String statusTopic = 'status';
const String commandTopic = 'command';
const String configTopic = 'config';
const String systemTopic = 'system';
const String valvesTopic = 'valves';

Map onStatusMap = {"cmd": 1};
Map offStatusMap = {"cmd": 0};
Map rebootStatusMap = {"cmd": 4};
Map deleteProgramMap = {"cmd": 5};
