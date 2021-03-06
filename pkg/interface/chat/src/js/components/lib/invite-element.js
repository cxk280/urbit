import React, { Component } from 'react';
import { InviteSearch } from './invite-search';


export class InviteElement extends Component {

  constructor(props) {
    super(props);
    this.state = {
      members: [],
      error: false,
      success: false
    };
    this.setInvite = this.setInvite.bind(this);
  }

  modifyMembers() {
    const { props, state } = this;

    let aud = state.members.map(mem => `~${mem}`);

    if (state.members.length === 0) {
      this.setState({
        error: true,
        success: false
      });
      return;
    }

    props.api.setSpinner(true);

    this.setState({
      error: false,
      success: true,
      members: []
    }, () => {
      props.api.groups.add(aud, props.path).then(() => {
        props.api.setSpinner(false);
      });
    });
  }

  setInvite(invite) {
    this.setState({members: invite.ships});
  }

  render() {
    const { props, state } = this;

    let modifyButtonClasses = "mt4 db f9 ba pa2 white-d bg-gray0-d b--black b--gray2-d pointer";
    if (state.error) {
      modifyButtonClasses = modifyButtonClasses + ' gray3';
    }

    let buttonText = '';
    if (props.permissions.kind === 'black') {
      buttonText = 'Ban';
    } else if (props.permissions.kind === 'white') {
      buttonText = 'Invite';
    }

    return (
      <div>
      <InviteSearch
        groups={{}}
        contacts={props.contacts}
        groupResults={false}
        shipResults={true}
        invites={{
          groups: [],
          ships: this.state.members
        }}
        setInvite={this.setInvite}
      />
        <button
          onClick={this.modifyMembers.bind(this)}
          className={modifyButtonClasses}>
          {buttonText}
        </button>
      </div>
    );
  }
}
