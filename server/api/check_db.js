const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('actress_puzzle_game', 'root', '', {
  host: '127.0.0.1',
  dialect: 'mysql',
  logging: false,
});

async function check() {
  try {
    const [results] = await sequelize.query("SELECT * FROM admins WHERE email = 'admin@example.com'");
    console.log("Admins:", results);
  } catch(e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}

check();
