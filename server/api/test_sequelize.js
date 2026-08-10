const { Admin } = require('./src/models');
const { sequelize } = require('./src/config/database');

async function test() {
  try {
    const admin = await Admin.findOne({ where: { email: 'admin@example.com' } });
    if (admin) {
      console.log('Admin keys:', Object.keys(admin.toJSON()));
      console.log('Admin password:', admin.password);
      console.log('Admin is_active:', admin.is_active);
    } else {
      console.log('Admin not found');
    }
  } catch (e) {
    console.error(e);
  } finally {
    await sequelize.close();
    process.exit(0);
  }
}

test();
