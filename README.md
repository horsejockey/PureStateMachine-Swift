# PureStateMachine

A simple pure state machine extracted from [this repo](https://github.com/rob-brown/Actor) by @rob-brown to separate out the Actor Model from the state machine. Additionaly it adds SPM support.

Based on Elm architecture and https://gist.github.com/andymatuschak/d5f0a8730ad601bcccae97e8398e25b2

Rob Brown's Actor + PureStateMachine: https://github.com/rob-brown/Actor

Actor Model only fork with SPM support: https://github.com/horsejockey/Actor-Swift

## Architecture

This implementation of a state machine is composed of a container of the current state and an event handler. The event handler recieves an event and based on the current state and that event it can choose to update it's current state, emit commands or side effects, do neither, or a combinaton of the two.


```
+-----------------+
|                 |
|  State Machine  |            +-------+
|                 +<-----------+ Event +------------+
|                 |            +-------+
|                 |
|                 |            +-------+
|                 |       +----+ State +------------>
|                 |       |    +-------+
| +-------------+ |       |
| |    State    | |       |    +------------------+
| |             | +------------+ State & Commands +->
| +-------------+ |       |    +------------------+
+-----------------+       |
                          |    +----------+
                          +----  Commands +--------->
                          |    +----------+
                          |
                          |    +-----------+
                          +----+ No Update +-------->
                               +-----------+

```
