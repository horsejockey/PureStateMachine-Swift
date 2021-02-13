//
// PureStateMachine.swift
//
// Copyright (c) 2018 Robert Brown
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import Actor

// Based on Elm architecture and https://gist.github.com/andymatuschak/d5f0a8730ad601bcccae97e8398e25b2

public final class PureStateMachine<State, Event, Command> {
    public typealias EventHandler = (State, Event) -> StateUpdate<State, Command>

    public var currentState: State {
        return state.fetch { $0 }
    }

    private let state: Agent<State>
    private let eventHandler: EventHandler
    private weak var handler: PureStateMachine?

    public convenience init(
        initialState: State,
        label: String = "pro.tricksofthetrade.PureStateMachine",
        eventHandler: @escaping EventHandler) {
        let state = Agent(state: initialState, label: label)
        self.init(state: state, eventHandler: eventHandler)
    }

    public convenience init(
        initialState: State,
        queue: DispatchQueue,
        eventHandler: @escaping EventHandler
    ) {
        let state = Agent(state: initialState, queue: queue)
        self.init(state: state, eventHandler: eventHandler)
    }

    private init(
        state: Agent<State>,
        eventHandler: @escaping EventHandler
    ) {
        self.state = state
        self.eventHandler = eventHandler
        
    }

    public func handleEvent(_ event: Event) -> StateUpdate<State, Command> {
        return state.fetchAndUpdate { currentState in
            let stateUpdate = self.eventHandler(currentState, event)
            return (stateUpdate, stateUpdate.state ?? currentState)
        }
    }
}

public enum StateUpdate<State, Command> {
    case NoUpdate
    case State(State)
    case Commands([Command])
    case StateAndCommands(State, [Command])
    
    public var state: State? {
        switch self {
        case .NoUpdate, .Commands:            return nil
        case .State(let state):               return state
        case .StateAndCommands(let state, _): return state
        }
    }
    
    public var commands: [Command] {
        switch self {
        case .NoUpdate, .State:                  return []
        case .Commands(let commands):            return commands
        case .StateAndCommands(_, let commands): return commands
        }
    }
    
    public func mapState<T>(_ closure: (State) -> T) -> StateUpdate<T, Command> {
        switch self {
        case .NoUpdate:
            return .NoUpdate
        case .Commands(let commands):
            return .Commands(commands)
        case .State(let state):
            return .State(closure(state))
        case .StateAndCommands(let state, let commands):
            return .StateAndCommands(closure(state), commands)
        }
    }
    
    public func mapCommands<T>(_ closure: (Command) -> T) -> StateUpdate<State, T> {
        switch self {
        case .NoUpdate:
            return .NoUpdate
        case .Commands(let commands):
            return .Commands(commands.map(closure))
        case .State(let state):
            return .State(state)
        case .StateAndCommands(let state, let commands):
            return .StateAndCommands(state, commands.map(closure))
        }
    }
}
