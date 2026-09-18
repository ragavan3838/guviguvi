// Automated Real-time Verification for PulsePoll
async function runTest() {
  console.log('--- Starting PulsePoll End-to-End Realtime Verification ---');

  // 1. Create a poll
  const pollData = {
    title: 'Real-time WebSocket & Redis Benchmark',
    description: 'Automated test suite verifying pub/sub broadcast',
    options: [
      { text: 'Sub-millisecond Latency', emoji: '⚡' },
      { text: 'Atomic Counters', emoji: '🔒' },
      { text: 'Live Reactions', emoji: '🎉' }
    ],
    settings: {
      allowMultiple: false,
      requireName: false,
      showResultsImmediate: true
    }
  };

  const createRes = await fetch('http://localhost:8080/api/polls', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(pollData)
  });

  if (!createRes.ok) {
    throw new Error('Failed to create poll: ' + (await createRes.text()));
  }

  const { poll, creatorToken } = await createRes.json();
  console.log(`[PASS] 1. Poll created successfully! ID: ${poll.id}`);

  // 2. Connect via native WebSocket
  const wsUrl = `ws://localhost:8080/ws/poll/${poll.id}`;
  const ws = new WebSocket(wsUrl);

  const receivedEvents = [];

  await new Promise((resolve, reject) => {
    ws.onopen = () => {
      console.log('[PASS] 2. WebSocket connected successfully to room:', poll.id);
      resolve();
    };
    ws.onerror = (err) => reject(new Error('WS connection failed: ' + err.message));
  });

  ws.onmessage = (evt) => {
    try {
      const msg = JSON.parse(evt.data);
      console.log(`[EVENT RECEIVED] Type: ${msg.type}`, JSON.stringify(msg.data));
      receivedEvents.push(msg);
    } catch (e) {
      console.error('Failed to parse WS msg:', e);
    }
  };

  // Wait a moment for viewer presence registration
  await new Promise(r => setTimeout(r, 400));

  // 3. Submit a vote
  console.log('Submitting vote via REST...');
  const voteRes = await fetch(`http://localhost:8080/api/polls/${poll.id}/vote`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      voterId: 'automated_voter_007',
      optionIds: ['opt_1']
    })
  });

  if (!voteRes.ok) {
    throw new Error('Failed to submit vote: ' + (await voteRes.text()));
  }
  console.log('[PASS] 3. Vote submitted successfully to Go backend');

  // 4. Send a live reaction
  console.log('Sending reaction...');
  const reactRes = await fetch(`http://localhost:8080/api/polls/${poll.id}/reaction`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ emoji: '🚀' })
  });

  if (!reactRes.ok) {
    throw new Error('Failed to send reaction');
  }
  console.log('[PASS] 4. Reaction sent successfully to Go backend');

  // 5. Wait to ensure all WS messages are received
  await new Promise(r => setTimeout(r, 800));

  ws.close();

  // Validate received events
  const hasVoteUpdate = receivedEvents.some(e => e.type === 'vote_update' && e.data?.votes?.opt_1 === 1);
  const hasReaction = receivedEvents.some(e => e.type === 'reaction' && e.data?.emoji === '🚀');

  console.log('\n--- Test Results ---');
  console.log(`- Vote update broadcast received over WebSocket: ${hasVoteUpdate ? 'YES [PASS]' : 'NO [FAIL]'}`);
  console.log(`- Reaction broadcast received over WebSocket: ${hasReaction ? 'YES [PASS]' : 'NO [FAIL]'}`);

  if (!hasVoteUpdate || !hasReaction) {
    throw new Error('Verification failed: missing expected real-time events over WebSocket!');
  }

  console.log('\nALL REAL-TIME VERIFICATION TESTS PASSED SUCCESSFULLY! 🚀');
}

runTest().catch((err) => {
  console.error('[FATAL ERROR]', err);
  process.exit(1);
});
