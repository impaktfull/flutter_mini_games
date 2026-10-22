/// What the attacker's hand is doing during a round
enum SlapAttackState {
  /// The defender is not holding their target yet: the attacker can't slap
  waitingForHold,

  /// The defender holds their target: the attacker may slap or fake
  armed,

  /// The hand is raised before it comes down. Looks the same for a slap and a fake
  windUp,

  /// A real slap is coming down on the target
  strike,

  /// A fake: the hand goes back without coming down
  retract,
}

/// How a round ended
enum SlapRoundEnd {
  /// The defender lifted their finger before the slap landed: point for the defender
  dodged,

  /// The defender still held the target when the slap landed: point for the attacker
  slapped,

  /// The defender lifted their finger on a fake: point for the attacker
  flinched,

  /// The attacker did not slap within the attack time: point for the defender
  tooSlow,
}
