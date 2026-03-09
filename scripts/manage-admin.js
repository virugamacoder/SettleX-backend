/**
 * Admin Role Manager
 *
 * Usage:
 *   node scripts/manage-admin.js add    <wallet_address> <chain_id>
 *   node scripts/manage-admin.js remove <wallet_address> <chain_id>
 *   node scripts/manage-admin.js list
 *
 * Examples:
 *   node scripts/manage-admin.js add    0xfEceA7b046b4DaFACE340c7A2fe924cf41b6d274 137
 *   node scripts/manage-admin.js remove 0xfEceA7b046b4DaFACE340c7A2fe924cf41b6d274 137
 *   node scripts/manage-admin.js list
 */

const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const mongoose = require('mongoose');

const MONGODB_URL = process.env.MONGODB_URL;
if (!MONGODB_URL) {
  console.error('❌  MONGODB_URL not found in .env');
  process.exit(1);
}

async function connect() {
  await mongoose.connect(MONGODB_URL + 'test', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
}

const User = require('../src/models/user.model');

// mirrors getUserByWalletAddressAndChainId
async function findUser(address, chainId) {
  return User.findOne({ primary_address: address, primary_chain: Number(chainId) });
}

async function addAdmin(address, chainId) {
  const user = await findUser(address, chainId);
  if (!user) {
    console.error(`❌  No record found for wallet ${address} on chain ${chainId}`);
    console.log('   → The wallet must log in on this chain at least once first.');
    return;
  }
  if (user.role === 'admin') {
    console.log(`ℹ️   Already admin  |  wallet: ${address}  |  chain: ${chainId}`);
    return;
  }
  await User.updateOne({ _id: user._id }, { $set: { role: 'admin' } });
  console.log(`✅  Role set to admin  |  wallet: ${address}  |  chain: ${chainId}`);
}

async function removeAdmin(address, chainId) {
  const user = await findUser(address, chainId);
  if (!user) {
    console.error(`❌  No record found for wallet ${address} on chain ${chainId}`);
    return;
  }
  if (user.role !== 'admin') {
    console.log(`ℹ️   Not an admin (role: ${user.role})  |  wallet: ${address}  |  chain: ${chainId}`);
    return;
  }
  await User.updateOne({ _id: user._id }, { $set: { role: 'user' } });
  console.log(`✅  Role set to user  |  wallet: ${address}  |  chain: ${chainId}`);
}

async function listAdmins() {
  const admins = await User.find({ role: 'admin', is_deleted: false }).lean();
  if (admins.length === 0) {
    console.log('No admin users found.');
    return;
  }
  console.log(`\nAdmin wallets (${admins.length}):`);
  admins.forEach((u) => console.log(`  • ${u.primary_address}  |  chain: ${u.primary_chain}`));
}

async function main() {
  const [action, address, chainId] = process.argv.slice(2);

  if (!['add', 'remove', 'list'].includes(action)) {
    console.log('Usage:');
    console.log('  node scripts/manage-admin.js add    <wallet_address> <chain_id>');
    console.log('  node scripts/manage-admin.js remove <wallet_address> <chain_id>');
    console.log('  node scripts/manage-admin.js list');
    process.exit(1);
  }

  if (action !== 'list' && (!address || !chainId)) {
    console.error(`❌  Both wallet_address and chain_id are required.`);
    console.log(`Usage: node scripts/manage-admin.js ${action} <wallet_address> <chain_id>`);
    process.exit(1);
  }

  try {
    await connect();

    if (action === 'add')    await addAdmin(address, chainId);
    if (action === 'remove') await removeAdmin(address, chainId);
    if (action === 'list')   await listAdmins();

  } catch (err) {
    console.error('❌  Error:', err.message);
  } finally {
    await mongoose.disconnect();
  }
}

main();
