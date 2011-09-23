class Command
  def method_missing *args
    "no such command #{args.inspect}"
  end
  def reload  args=nil
    s = ''
    begin
      body = Helper.get_body CONFIG['replies_url']
      File.open('replies.yml','w') { |f| f.write body }
      $replies = YAML.load_file('replies.yml')
      s = "RELOADED TEH $replies file"
    rescue
      s = "CANT RELOAD, file BORKED"
    end
    s
  end


  def test args=[]
    args.join ' - '
  end
end
