const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: 'd:/Project/Mobile_project/backend/.env' });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function test() {
  const { data, error } = await supabase.from('driver').select('*').limit(1);
  if (data && data.length > 0) {
    console.log('Columns in driver table:', Object.keys(data[0]));
  } else if (error) {
    console.log('Error fetching driver table:', error);
  } else {
    console.log('Driver table is empty.');
  }
}

test();
