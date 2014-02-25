# -*- coding: utf-8 -*-
require "xz"

class Emerge < ActiveRecord::Base
  belongs_to :package
  belongs_to :user
  has_many :comments, :as => :commentable

  default_scope select([:id, :buildtime, :duration, :package_id, :user_id])

  def fullname
    self.package.fullname
  end
  def page
    "/emerges/" + self.id.to_s
  end

  def pretty_duration
    dur = self.duration
    days = dur.divmod(24*60*60)
    hours = days[1].divmod(60*60)
    mins = hours[1].divmod(60)

    if days[0] > 0
      days[0].to_s + t(:day) + hours[0].to_s + t(:hour) + mins[0].to_s + t(:minute)
    elsif hours[0] > 0
      hours[0].to_s + t(:hour) + mins[0].to_s + t(:minute)
    elsif mins[0] > 0
      mins[0].to_s + t(:minute) + mins[1].to_s + t(:second)
    else
      mins[1].to_s + t(:second)
    end
  end

  def hash_file(hash)
    "data/" + hash[0,2] + "/" + hash[2,4] + "/" + hash[4..-1]
  end

  def save_hash_file(contents)
    hash = Digest::SHA256.hexdigest(contents)
    file = hash_file(hash)
    dir = File.dirname(file)
    unless File.exists?(file)
      FileUtils.mkdir_p(dir)
      File.binwrite(file, XZ.compress(contents))
    end
    hash
  end

  def hashed_log(log, hash)
    if hash
      file = hash_file(hash)
      XZ.decompress(File.open(file).read)
    else
      log.force_encoding("UTF-8")
    end
  end
end
