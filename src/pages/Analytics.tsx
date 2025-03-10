import React, { useState, useEffect } from 'react';
import { Calendar, Loader2, Users, PhoneCall, Mail, MessageSquare } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../lib/auth';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart, Pie, Cell,
  Legend
} from 'recharts';
import type { Lead, Feedback } from '../types';

type DateFilter = 'today' | '7days' | '14days' | '30days' | 'all';

// Constant for estimated views (used across the application)
const ESTIMATED_TOTAL_VIEWS = 50;

interface DailyStats {
  date: string;
  count: number;
  conversionRate: number;
}

interface FlowStats {
  option: string;
  count: number;
  percentage: number;
  color: string;
}

export function Analytics() {
  const [loading, setLoading] = useState(true);
  const [leads, setLeads] = useState<Lead[]>([]);
  const [feedback, setFeedback] = useState<Feedback[]>([]);
  const { user } = useAuth();
  const [dateFilter, setDateFilter] = useState<DateFilter>('30days');
  const [dailyStats, setDailyStats] = useState<DailyStats[]>([]);
  const [flowStats, setFlowStats] = useState<FlowStats[]>([]);
  const [locationStats, setLocationStats] = useState<{
    cities: { name: string; count: number }[];
    countries: { name: string; count: number }[];
  }>({ cities: [], countries: [] });

  const dateFilters: { value: DateFilter; label: string }[] = [
    { value: 'today', label: 'Today' },
    { value: '7days', label: 'Last 7 days' },
    { value: '14days', label: 'Last 14 days' },
    { value: '30days', label: 'Last 30 days' },
    { value: 'all', label: 'All time' },
  ];

  const getDateRange = (filter: DateFilter) => {
    const now = new Date();
    now.setHours(23, 59, 59, 999);
    
    switch (filter) {
      case 'today':
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        return today.toISOString();
      case '7days':
        const sevenDays = new Date(now);
        sevenDays.setDate(now.getDate() - 7);
        return sevenDays.toISOString();
      case '14days':
        const fourteenDays = new Date(now);
        fourteenDays.setDate(now.getDate() - 14);
        return fourteenDays.toISOString();
      case '30days':
        const thirtyDays = new Date(now);
        thirtyDays.setDate(now.getDate() - 30);
        return thirtyDays.toISOString();
      default:
        return null;
    }
  };

  useEffect(() => {
    fetchLeads();
    fetchFeedback();
  }, [dateFilter]);

  const fetchFeedback = async () => {
    try {
      let query = supabase
        .from('feedback')
        .select('*')
        .eq('chatbot_id', user?.id);

      const dateRange = getDateRange(dateFilter);
      if (dateRange) {
        query = query.gte('created_at', dateRange);
      }

      const { data, error } = await query.order('created_at', { ascending: false });
      if (error) throw error;
      setFeedback(data || []);
    } catch (error) {
      console.error('Error fetching feedback:', error);
    }
  };

  const fetchLeads = async () => {
    setLoading(true);
    try {
      if (!user?.id) {
        throw new Error('User not authenticated');
      }

      let query = supabase
        .from('leads')
        .select('*')
        .eq('chatbot_id', user?.id);

      const dateRange = getDateRange(dateFilter);
      if (dateRange) {
        query = query.gte('created_at', dateRange);
      }

      const { data, error } = await query.order('created_at', { ascending: true });

      if (error) throw error;
      setLeads(data || []);
      calculateDailyStats(data || []);
      calculateFlowStats(data || []);
      calculateLocationStats(data || []);
    } catch (error) {
      console.error('Error fetching leads:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateLocationStats = (leads: Lead[]) => {
    const cities = new Map<string, number>();
    const countries = new Map<string, number>();

    leads.forEach(lead => {
      if (lead.location?.city) {
        cities.set(lead.location.city, (cities.get(lead.location.city) || 0) + 1);
      }
      if (lead.location?.country) {
        countries.set(lead.location.country, (countries.get(lead.location.country) || 0) + 1);
      }
    });

    setLocationStats({
      cities: Array.from(cities.entries())
        .map(([name, count]) => ({ name, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 5),
      countries: Array.from(countries.entries())
        .map(([name, count]) => ({ name, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 5)
    });
  };

  const calculateDailyStats = (leads: Lead[]) => {
    const stats = new Map<string, { count: number; conversionRate: number }>();
    
    // Calculate daily conversion rate based on total views
    const dailyViews = ESTIMATED_TOTAL_VIEWS;
    
    // Initialize dates
    const endDate = new Date();
    const startDate = new Date(getDateRange(dateFilter) || endDate);
    
    for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
      const dateStr = d.toISOString().split('T')[0];
      stats.set(dateStr, { count: 0, conversionRate: 0 });
    }

    // Count leads per day
    leads.forEach(lead => {
      const dateStr = new Date(lead.created_at).toISOString().split('T')[0];
      const current = stats.get(dateStr) || { count: 0, conversionRate: 0 };
      const newCount = current.count + 1;
      const conversionRate = Math.round((newCount / dailyViews) * 100);
      stats.set(dateStr, { count: newCount, conversionRate });
    });

    // Convert to array
    const dailyStatsArray = Array.from(stats.entries()).map(([date, data]) => ({
      date,
      count: data.count,
      conversionRate: data.conversionRate
    }));

    setDailyStats(dailyStatsArray);
  };

  const calculateFlowStats = (leads: Lead[]) => {
    const optionCounts = leads.reduce((acc, lead) => {
      // Get the first answer which should be the flow choice
      const [, flowChoice] = Object.entries(lead.answers)[0] || ['', 'Unknown Path'];
      // Clean up the flow choice text
      const option = flowChoice.charAt(0).toUpperCase() + flowChoice.slice(1);
      acc[option] = (acc[option] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const total = Object.values(optionCounts).reduce((sum, count) => sum + count, 0);
    
    const colors = ['#a7e154', '#54e1a7', '#5454e1', '#e154a7'];
    
    const stats = Object.entries(optionCounts).map(([option, count], index) => ({
      option,
      count,
      percentage: Math.round((count / total) * 100),
      color: colors[index % colors.length]
    }));

    setFlowStats(stats);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="w-8 h-8 animate-spin text-brand" />
      </div>
    );
  }

  const totalLeads = leads.length;
  const conversionRate = Math.round((totalLeads / ESTIMATED_TOTAL_VIEWS) * 100);
  
  const uniqueEmails = new Set(leads.map(lead => lead.email)).size;
  const uniquePhones = new Set(leads.map(lead => lead.phone).filter(Boolean)).size;

  // Calculate feedback stats
  const totalFeedback = feedback.length;
  const satisfiedCount = feedback.filter(f => f.satisfied).length;
  const satisfactionRate = totalFeedback > 0 
    ? Math.round((satisfiedCount / totalFeedback) * 100) 
    : 0;

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-100">Analytics</h1>
        <div className="flex items-center space-x-2">
          <Calendar className="w-5 h-5 text-gray-400" />
          {dateFilters.map(({ value, label }) => (
            <button
              key={value}
              onClick={() => setDateFilter(value)}
              className={`px-3 py-1.5 rounded-md text-sm whitespace-nowrap transition-colors
                ${dateFilter === value
                  ? 'bg-brand text-black'
                  : 'bg-dark-700 text-gray-400 hover:text-brand hover:bg-dark-600'
                }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
        <div className="bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-400 mb-2">Total Leads</h3>
              <p className="text-3xl font-bold text-gray-100">{totalLeads}</p>
            </div>
            <Users className="w-8 h-8 text-brand" />
          </div>
        </div>
        
        <div className="bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-400 mb-2">Unique Emails</h3>
              <p className="text-3xl font-bold text-gray-100">{uniqueEmails}</p>
            </div>
            <Mail className="w-8 h-8 text-brand" />
          </div>
        </div>
        
        <div className="bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-400 mb-2">Unique Phone Numbers</h3>
              <p className="text-3xl font-bold text-gray-100">{uniquePhones}</p>
            </div>
            <PhoneCall className="w-8 h-8 text-brand" />
          </div>
        </div>
        
        <div className="bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-400 mb-2">Conversion Rate</h3>
              <p className="text-3xl font-bold text-gray-100">{conversionRate}%</p>
            </div>
            <MessageSquare className="w-8 h-8 text-brand" />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Location Stats */}
        <div className="bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <h2 className="text-lg font-medium text-gray-100 mb-4">Top Locations</h2>
          
          <div className="space-y-6">
            <div>
              <h3 className="text-sm font-medium text-gray-400 mb-2">Top Cities</h3>
              <div className="space-y-2">
                {locationStats.cities.map(({ name, count }) => (
                  <div key={name} className="flex items-center justify-between">
                    <span className="text-gray-300">{name}</span>
                    <span className="text-brand font-medium">{count}</span>
                  </div>
                ))}
              </div>
            </div>
            
            <div>
              <h3 className="text-sm font-medium text-gray-400 mb-2">Top Countries</h3>
              <div className="space-y-2">
                {locationStats.countries.map(({ name, count }) => (
                  <div key={name} className="flex items-center justify-between">
                    <span className="text-gray-300">{name}</span>
                    <span className="text-brand font-medium">{count}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        <div className="lg:col-span-2 bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <h2 className="text-lg font-medium text-gray-100 mb-4">Lead Acquisition</h2>
          <div className="h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={dailyStats}>
                <defs>
                  <linearGradient id="colorCount" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#a7e154" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#a7e154" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis
                  dataKey="date"
                  stroke="#9CA3AF"
                  tick={{ fill: '#9CA3AF' }}
                  tickFormatter={(value) => new Date(value).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                />
                <YAxis stroke="#9CA3AF" tick={{ fill: '#9CA3AF' }} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1a1a1a',
                    border: '1px solid #374151',
                    borderRadius: '0.5rem',
                  }}
                  labelStyle={{ color: '#9CA3AF' }}
                  itemStyle={{ color: '#a7e154' }}
                  labelFormatter={(value) => new Date(value).toLocaleDateString()}
                />
                <Area
                  type="monotone"
                  dataKey="count"
                  stroke="#a7e154"
                  fillOpacity={1}
                  fill="url(#colorCount)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Feedback Stats */}
        <div className="lg:col-span-3 bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <h2 className="text-lg font-medium text-gray-100 mb-4">User Satisfaction</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="p-4 bg-dark-700 rounded-lg">
              <h3 className="text-sm font-medium text-gray-400 mb-2">Total Feedback</h3>
              <p className="text-3xl font-bold text-gray-100">{totalFeedback}</p>
            </div>
            <div className="p-4 bg-dark-700 rounded-lg">
              <h3 className="text-sm font-medium text-gray-400 mb-2">Satisfied Users</h3>
              <p className="text-3xl font-bold text-brand">{satisfiedCount}</p>
            </div>
            <div className="p-4 bg-dark-700 rounded-lg">
              <h3 className="text-sm font-medium text-gray-400 mb-2">Satisfaction Rate</h3>
              <p className="text-3xl font-bold text-gray-100">{satisfactionRate}%</p>
            </div>
          </div>
          
          <div className="mt-6">
            <h3 className="text-sm font-medium text-gray-400 mb-4">Recent Feedback</h3>
            <div className="space-y-2">
              {feedback.slice(0, 5).map(item => (
                <div 
                  key={item.id}
                  className="flex items-center justify-between p-3 bg-dark-700 rounded-lg"
                >
                  <div className="flex items-center space-x-2">
                    <div 
                      className={`w-2 h-2 rounded-full ${
                        item.satisfied ? 'bg-green-500' : 'bg-red-500'
                      }`}
                    />
                    <span className="text-gray-300">
                      {item.satisfied ? 'Satisfied' : 'Not Satisfied'}
                    </span>
                  </div>
                  <span className="text-sm text-gray-400">
                    {new Date(item.created_at).toLocaleDateString()}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="bg-dark-800 rounded-lg shadow-lg border border-gray-800 p-6">
          <h2 className="text-lg font-medium text-gray-100 mb-4">Flow Distribution</h2>
          <div className="h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={flowStats}
                  dataKey="count"
                  nameKey="option"
                  cx="50%"
                  cy="50%"
                  outerRadius={80}
                  innerRadius={50}
                  label={({ percentage }) => `${percentage}%`}
                >
                  {flowStats.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Legend
                  layout="vertical"
                  align="center"
                  verticalAlign="top"
                  wrapperStyle={{
                    paddingBottom: '20px'
                  }}
                  formatter={(value) => (
                    <span className="text-sm text-gray-100">{value}</span>
                  )}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1a1a1a',
                    border: '1px solid #374151',
                    borderRadius: '0.5rem',
                  }}
                  formatter={(value, name) => [
                    `${value} leads (${flowStats.find(stat => stat.option === name)?.percentage}%)`
                  ]}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}