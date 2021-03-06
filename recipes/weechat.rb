# encoding: UTF-8
#
# Cookbook Name:: wergstation
#
# Recipe:: weechat
#
# Copyfree (F) 2014 Carlton Stedman
#

ns = node["wergstation"]

# user's id, group, home
id, grp, home = %w{ id group home }.map { |k| ns["user"][k] }

# ~/.weechat dir
dotweechat = ::File.join(home, ".weechat")

## Install weechat
#
package "weechat" do
  action :install
end

## Create ~/.weechat and populate with files
#
remote_directory dotweechat do
  files_group grp
  files_mode "0640"
  files_owner id
  group grp
  mode "0750"
  owner id

  # don't delete already existing files
  purge false
  source "home/dotweechat"
  action :create
end

## Render weechat configs
#
%w{ irc
    weechat }.
  map { |conf| "#{conf}.conf" }.
  each do |conf|
    template ::File.join(dotweechat, conf) do
      group grp
      mode "0640"
      owner id
      source "home/dotweechat/#{conf}.erb"
      variables(:settings => ns["weechat"])
      action :create
    end
  end
