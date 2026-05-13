const supabase = require('./dbClient');

class UserModel {
  // Get user profile by username (phone number)
  static async getProfileByUsername(username) {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('username', username)
      .maybeSingle();

    if (error) {
      throw error;
    }
    return data;
  }

  // Update user profile
  static async updateProfile(username, profileData) {
    const { data, error } = await supabase
      .from('profiles')
      .update(profileData)
      .eq('username', username)
      .select()
      .maybeSingle();

    if (error) {
      throw error;
    }
    return data;
  }
}

module.exports = UserModel;
