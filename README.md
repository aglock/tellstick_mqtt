# tellstick_mqtt
Docker container to transmit TellStick events via MQTT

# MQTT Broker for Telldus Core (Tellstick)
Uses libtelldus-core (Tellstick) to transmit events to MQTT. These events can then be used from different home automation / smart home utilities like [Home Assistant](https://home-assistant.io/) and [OpenHAB](http://www.openhab.org/) or your own custom handlers and loggers.

# Configuration

The broker is configured in`telldusmq.json` and the tellstick device is configure in `tellstick.conf`. 
Access to Tellstick USB devidce is also necessary, either by mounting via volume or running container in priveleged mode.
Both files should be added as volumes via:
~~~~
devices:
  - "dev/bus/usb:dev/bus/usb"
volumes:
  - /host/folder/telldusmq.json:/etc/telldusmq/telldusmq.json
  - /host/folder/tellstick.conf:/etc/tellstick.conf
~~~~

## Receiving Events From Tellstick

The MQTT parameters for topic and payload, can contain template variables (from Go text/template package). The templates are executed on an object containing the event from Tellstick with the following properties:

  - Class
  - Protocol
  - Model
  - Code
  - House
  - Unit
  - Group
  - Method
  - Id
  - Temp
  - Humidity
  - Value
  - DataType

We can then use the variables like this: `Temperature for id#{{.Id}} is: {{.Temp}}`

Some sensors supports both temperature and humidity and if you wish to have a separate event for both these types, you can set the configuration item `Tellstick => SplitTemperatureAndHumidity` to `true`. The `Value` property will contain the value (temperature or humidity) and the `DataType` property will contain `temp` or `humidity`. The sample configuration reflects this.

Telldus Core reports device methods as `turnon` or `turnoff` by default. If you wish to map these to other values like `ON` or `OFF`, `1` or `0` etc, this can be configured with setting `Tellstick => MapTurnOnTo` and `Tellstick => MapTurnOffTo` to the appropriate strings.

## Transmitting Events To Tellstick

Telldus-core allows to transmit commands to devices. The broker subscribes to the MQTT-topic defined in `MQTT => Events => SubscribeTopic`. Currently we support two methods for transmitting commands; devices from tellstick.conf and raw commands.

### Tellstick.conf Device

A few methods in telldus-core for transmitting actions are implemented. These are `turnoff`, `turnon`, `learn` and `dim`. The MQTT-payload for these events must be formatted like this:

```json
{"protocol":"telldusdevice", "method":"turnon", "device_id": 145}
```

```json
{"protocol":"telldusdevice", "method":"dim", "device_id": 145, "level": 25}
```

The `method` can be one of the described methods above, and `device_id` must be a device defined in tellstick.conf. Protocol must be `telldusdevice`.

We also listen to the topic defined in `MQTT => Events => SubscribeDeviceEvents`. This topic can either be a specified device id like `tellstick/device/events/13` or a wild card defining all devices `tellstick/device/events/#`. The payload for these events is simply the Tellstick method described above.

### Raw Commands

We don't really support raw commands yet, but we hopefully will very soon. There is some initial support for archtech, but it probably won't work.

The WIP is published anyway. MQTT-payload for these are:

```json
{"protocol":"archtech", "house": 12345, "unit": 9, "method": "turnoff"}
```

```json
{"protocol":"archtech", "house": 12345, "unit": 9, "method": "dim", "level": 25}
```

#### Raw Commands TODO
- Implement archtech properly
- Implement more protocols
- Implement proper protocol-switching

