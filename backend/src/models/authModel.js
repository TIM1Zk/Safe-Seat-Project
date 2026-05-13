const supabase = require('./dbClient');

class AuthModel {
  static async login(username, password) {
    const { data, error } = await supabase
      .from('user')
      .select('*')
      .eq('username', username)
      .eq('password', password)
      .maybeSingle();
      
    if (error) throw error;
    return data;
  }
}
module.exports = AuthModel;
